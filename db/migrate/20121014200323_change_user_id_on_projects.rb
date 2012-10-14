class ChangeUserIdOnProjects < ActiveRecord::Migration
  def up
    change_column :projects, :user_id, :integer, :null => true
  end

  def down
    change_column :projects, :user_id, :integer, :null => false
  end
end
