class CreatePlanRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :plan_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.text :prompt, null: false
      t.string :timezone, null: false, default: "Europe/Moscow"
      t.string :status, null: false, default: "pending"
      t.string :model
      t.jsonb :draft
      t.text :raw_response
      t.string :error
      t.datetime :completed_at
      t.datetime :applied_at
      t.timestamps
    end
    add_index :plan_requests, %i[user_id created_at]
    add_index :plan_requests, :status
  end
end
