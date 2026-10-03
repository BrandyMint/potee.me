# Traffic source follows the fleet standard attribution/v1 (corp-sales):
# the first-touch object of sales-intake/v1 instead of a bare ?ref= value.
class ReplaceTrafficSourceWithAttribution < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :attribution, :jsonb
    execute <<~SQL
      UPDATE users SET attribution = jsonb_strip_nulls(jsonb_build_object(
        'referrer', CASE WHEN referrer IS NOT NULL THEN 'https://' || referrer END,
        'utm', CASE WHEN source = 'share' THEN jsonb_build_object('source', 'potee', 'medium', 'share')
                    WHEN source IS NOT NULL THEN jsonb_build_object('source', source) END))
      WHERE source IS NOT NULL OR referrer IS NOT NULL
    SQL
    remove_index :users, :source
    remove_column :users, :source
    remove_column :users, :referrer
  end

  def down
    add_column :users, :source, :string
    add_column :users, :referrer, :string
    add_index :users, :source
    execute <<~SQL
      UPDATE users SET source = attribution->'utm'->>'source', referrer = split_part(attribution->>'referrer', '/', 3)
      WHERE attribution IS NOT NULL
    SQL
    remove_column :users, :attribution
  end
end
