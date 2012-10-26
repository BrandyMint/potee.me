class AddLastSignInAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_sign_in_at, :datetime
  end
end
