class CreateProjectConnections < ActiveRecord::Migration
  def change
    create_table :project_connections do |t|
      t.references :project, null: false
      t.references :user, null: false
      t.integer :position, null: false, default: 0
      t.string :share_key, null: false

      t.timestamps
    end
    add_index :project_connections, :project_id
    add_index :project_connections, [:user_id, :project_id], unique: true
    add_index :project_connections, [:user_id, :position]
    add_index :project_connections, :share_key, unique: true

    Project.find_each do |project|
      ProjectConnection.create project: project, user: project.user, position: (project.position || 1)
    end
  end
end
