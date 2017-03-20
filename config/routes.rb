Rails.application.routes.draw do
  resources :products, only: [:index]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'accounts#registration' # shortcut for the above
  post "/generate_otp" => "accounts#generate_otp", as: "generate"
  get '/user_otp' => "accounts#user_otp"
  post "/authenticate" => "accounts#authenticate"
  get '/userdetails' => "accounts#userdetails"

end
