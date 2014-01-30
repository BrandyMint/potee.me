class AddColorIndexToProjectConnections < ActiveRecord::Migration
  def change
    add_column :project_connections, :color_index, :integer, null: false, default: 0

    ProjectConnection.find_each do |pc|
      pc.update_column :color_index, pc.color_index
    end

    remove_column :projects, :color_index
    remove_column :projects, :position
  end
end
