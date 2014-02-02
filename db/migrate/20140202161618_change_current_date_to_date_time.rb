class ChangeCurrentDateToDateTime < ActiveRecord::Migration
  def up
    change_column :dashboards, :current_date, :datetime
  end

  def down
    change_column :dashboards, :current_date, :date
  end
end
