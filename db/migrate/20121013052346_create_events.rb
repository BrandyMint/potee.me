class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title, :null => false
      t.integer :project_id, :null => false

      t.timestamps
    end

    add_index :events, :project_id
  end
end
