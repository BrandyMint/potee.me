class AddDetailsToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :started_at, :date, :null => false
    add_column :projects, :finish_at, :date
    add_column :projects, :color_index, :integer, :null => false, :default => 0
  end
end
