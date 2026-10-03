class AddTrafficSourceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :source, :string
    add_column :users, :referrer, :string
    add_index :users, :source
  end
end
