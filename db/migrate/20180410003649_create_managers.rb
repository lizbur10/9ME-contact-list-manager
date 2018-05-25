class CreateManagers < ActiveRecord::Migration[5.1]
  def change
    create_table :managers do |t|
      t.string :name
      t.string :contact_info
      t.string :market
      t.string :role

      t.timestamps
    end
  end
end
