class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :provider, null: false
      t.string :uid, null: false

      t.timestamps
    end
  end
end
