class CreateCoreTables < ActiveRecord::Migration[8.1]
  def change
    # A user without an email is anonymous: the board works before sign-up.
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.datetime :last_seen_at
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :dashboards do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :pixels_per_day, null: false, default: 150
      t.datetime :current_date
      t.integer :scroll_top, null: false, default: 0
      t.timestamps
    end

    create_table :projects do |t|
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.string :title, null: false, limit: 255
      t.date :started_on, null: false
      t.date :finished_on, null: false
      # Sample projects of a new board; cleared once the user changes them.
      t.boolean :demo, null: false, default: false
      t.timestamps
    end

    create_table :project_connections do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.integer :color_index, null: false, default: 0
      t.string :share_key, null: false
      t.timestamps
    end
    add_index :project_connections, :share_key, unique: true
    add_index :project_connections, %i[user_id project_id], unique: true
    add_index :project_connections, %i[user_id position]

    create_table :events do |t|
      t.references :project, null: false, foreign_key: true
      t.string :title, null: false, limit: 255
      t.datetime :at, null: false
      t.timestamps
    end
    add_index :events, %i[project_id at]
  end
end
