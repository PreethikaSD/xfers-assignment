class AccountsController < ApplicationController
	XFERS_APP_API_KEY = 'CSTbn7g59YbtxDEyqy5o7AdJQxWu6paTyuhQbbyysQk'
	APP_SECRET_KEY = 'xeo_FyYHy-Z7aHsxQPH129hizjB3FyNtmp5-uLptcNo'

	def generate_otp
		phone_no = params[:phone_no]
		get_signature = Digest::SHA1.hexdigest(phone_no+APP_SECRET_KEY)
		Xfers.set_sg_sandbox
		begin
			puts 'Authorizing connect...'
			params = {
		  'phone_no'=> phone_no,
		  'signature'=> get_signature
			}
			resp = Xfers::Connect.authorize params, XFERS_APP_API_KEY
			rescue Xfers::XfersError => e
			puts e.to_s
		end
		if resp[:msg] == "success"
			redirect_to user_otp_path
			@account = Account.create(phone_no: phone_no)
		else
			flash[:alert] = e.to_s
			render :registration
		end

	end

	def registration
	end


	def user_otp
		@account = Account.last 
	end


	def authenticate
		otp = params[:otp]
		@account = Account.last
		Xfers.set_sg_sandbox
		begin
		  puts 'Getting connect token...'
		  params = {
		      'otp'=> otp,
		      'phone_no'=> @account.phone_no,
		      'signature'=> get_signature_authenticate(@account.phone_no, otp),
		      'return_url'=> 'https://mywebsite.com/api/v3/account_registration/completed'
		  }
		  resp = Xfers::Connect.get_token params, XFERS_APP_API_KEY
		  user_api_token =  resp[:user_api_token]
		  @account.user_api_token = user_api_token
		  @account.save

		  # You can now call Xfers.set_api_key again to change the X-XFERS-USER-API-KEY to the returned user_api_token 
		  # and make API calls on behalf of the connect user.

		  Xfers.set_api_key user_api_token

		  connect_user = Xfers::User.retrieve
		  puts connect_user[:first_name]
		  puts connect_user[:last_name]
		  puts connect_user[:available_balance]
		  puts connect_user

		rescue Xfers::XfersError => e
		  puts e.to_s
		end
	end


	private

	def listing_params
        params.require(:listing).permit(:title, :address, :price, :country_code, :remove_avatars, tag_ids: [], avatars: [])
    end

    def get_signature_authenticate(phone_no,otp)
		get_signature = Digest::SHA1.hexdigest(phone_no+otp+APP_SECRET_KEY)
	end    	

end
