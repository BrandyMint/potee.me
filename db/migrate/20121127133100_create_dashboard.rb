class CreateDashboard < ActiveRecord::Migration
  def up
    create_table :dashboards do |t|
      t.integer :pixel_scale, :default => 145
      t.date :current_date
      t.references :user
      t.timestamps
    end

    User.all.each do |user|
      Dashboard.create(user: user, pixel_scale: 145)
    end
  end

  def down
    drop_table :dashboards
  end
end
