class CreateDashboard < ActiveRecord::Migration
  def up
    create_table :dashboards do |t|
      t.integer :pixels_per_day, :default => 145
      t.date :current_date
      t.references :user, :null => false
      t.timestamps
    end
    add_index :dashboards, :user_id, :unique => true

    User.all.each do |user|
      Dashboard.create(user: user, pixels_per_day: 145, current_date: Time.now)
    end
  end

  def down
    drop_table :dashboards
  end
end