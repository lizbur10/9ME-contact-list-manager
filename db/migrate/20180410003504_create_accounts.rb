class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :company_name
      t.string :market
      t.string :email_list
      t.string :location
      t.string :delivery_day
      t.string :delivery_window
      t.integer :manager_id

      t.timestamps
    end
  end
end
