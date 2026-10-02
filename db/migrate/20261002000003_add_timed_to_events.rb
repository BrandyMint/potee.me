class AddTimedToEvents < ActiveRecord::Migration[8.1]
  # An event is "timed" when it happens at a specific time (a call at 19:00),
  # not just on a day. Until now untimed events got 12:00, so existing events
  # at any other Moscow time are marked timed.
  def up
    add_column :events, :timed, :boolean, null: false, default: false
    # `at` is a timestamp without zone holding UTC: tag it as UTC first.
    execute <<~SQL
      UPDATE events SET timed = TRUE
      WHERE to_char((at AT TIME ZONE 'UTC') AT TIME ZONE 'Europe/Moscow', 'HH24:MI') <> '12:00'
    SQL
  end

  def down
    remove_column :events, :timed
  end
end
