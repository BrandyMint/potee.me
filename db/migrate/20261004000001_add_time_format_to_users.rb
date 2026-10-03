class AddTimeFormatToUsers < ActiveRecord::Migration[8.1]
  def change
    # "24h" or "12h"; empty means the default of the interface language.
    add_column :users, :time_format, :string
  end
end
