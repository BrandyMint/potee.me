class RemoveIndexOfProjectsTitle < ActiveRecord::Migration
  def up
    remove_index :projects, :title #, :unique => true
    add_index :projects, :title
  end

  def down
    add_index :projects, :title, :unique => true
    remove_index :projects, :title
  end
end
