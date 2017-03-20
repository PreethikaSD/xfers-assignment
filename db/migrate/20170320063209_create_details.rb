class CreateDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :details do |t|
    	t.belongs_to :account, index: true

    	t.string :bank_name
    	t.integer :balance
    	t.string :account_number
    	t.string :unique_id

      t.timestamps
    end
  end
end
