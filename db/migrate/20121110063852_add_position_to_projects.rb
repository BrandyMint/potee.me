class AddPositionToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :position, :integer
    Project.update_all ["position = ?", nil]
  end
end
