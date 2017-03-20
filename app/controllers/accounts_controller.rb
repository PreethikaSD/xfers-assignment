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
		details = []
		otp = params[:otp]
		get_account
		Xfers.set_sg_sandbox
		begin
		  puts 'Getting connect token...'
		  params = {
		      'otp'=> otp,
		      'phone_no'=> @account.phone_no,
		      'signature'=> get_signature_authenticate(@account.phone_no, otp),
		      'return_url'=> 'http://localhost:3000/userdetails'
		  }
		  @resp = Xfers::Connect.get_token params, XFERS_APP_API_KEY
		  user_api_token =  @resp[:user_api_token]
		  @account.user_api_token = user_api_token
		  @account.save

		  # You can now call Xfers.set_api_key again to change the X-XFERS-USER-API-KEY to the returned user_api_token 
		  # and make API calls on behalf of the connect user.

		  Xfers.set_api_key user_api_token

		  @connect_user = Xfers::User.retrieve
		  redirect_to userdetails_path
		rescue Xfers::XfersError => e
		  puts e.to_s
		end
	end


	def userdetails
		get_account
		Xfers.set_sg_sandbox

		Xfers.set_api_key get_account.user_api_token
		@connect_user = Xfers::User.retrieve
		@available_bal = @connect_user[:available_balance]
		@resp = Xfers::User.transfer_info
		@bank_name = @resp[:bank_name_full]
		@account_no = @resp[:bank_account_no]
		@unique_id = @resp[:unique_id]

	end

	private

    def get_signature_authenticate(phone_no,otp)
		get_signature = Digest::SHA1.hexdigest(phone_no+otp+APP_SECRET_KEY)
	end    	

	def get_account
		@account = Account.last 
	end	

end
