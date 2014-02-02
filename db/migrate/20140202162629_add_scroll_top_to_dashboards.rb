class AddScrollTopToDashboards < ActiveRecord::Migration
  def change
    add_column :dashboards, :scroll_top, :integer, null: false, default: 0
  end
end
