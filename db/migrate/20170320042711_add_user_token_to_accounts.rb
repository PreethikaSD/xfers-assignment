class AddUserTokenToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :user_api_token, :string
  end
end
