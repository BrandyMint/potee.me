class AddSettingsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :locale, :string
    add_column :users, :region, :string
    add_column :users, :dim_days_off, :boolean, null: false, default: true

    # Accounts so far were made in Russia.
    reversible { |dir| dir.up { execute "UPDATE users SET region = 'RU' WHERE email IS NOT NULL" } }
  end
end
