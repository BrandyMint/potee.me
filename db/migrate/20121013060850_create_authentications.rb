class CreateAuthentications < ActiveRecord::Migration
  def change
    change_table(:users) do |t|
      t.remove :provider
      t.remove :uid
    end

    create_table(:authentications) do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.integer :user_id, null: false
    end
  end
end
