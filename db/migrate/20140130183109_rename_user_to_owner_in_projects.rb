class RenameUserToOwnerInProjects < ActiveRecord::Migration
  def up
    rename_column :projects, :user_id, :owner_id
  end
end
