class AddDateTimeToEvents < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.date :date, null: false
      t.time :time, null: false
    end
  end
end
