# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_02_000004) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "dashboards", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "pixels_per_day", default: 150, null: false
    t.datetime "current_date"
    t.integer "scroll_top", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_dashboards_on_user_id", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "title", limit: 255, null: false
    t.datetime "at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "timed", default: false, null: false
    t.index ["project_id", "at"], name: "index_events_on_project_id_and_at"
    t.index ["project_id"], name: "index_events_on_project_id"
  end

  create_table "plan_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "prompt", null: false
    t.string "timezone", default: "Europe/Moscow", null: false
    t.string "status", default: "pending", null: false
    t.string "model"
    t.jsonb "draft"
    t.text "raw_response"
    t.string "error"
    t.datetime "completed_at"
    t.datetime "applied_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_plan_requests_on_status"
    t.index ["user_id", "created_at"], name: "index_plan_requests_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_plan_requests_on_user_id"
  end

  create_table "project_connections", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.integer "position", default: 0, null: false
    t.integer "color_index", default: 0, null: false
    t.string "share_key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_connections_on_project_id"
    t.index ["share_key"], name: "index_project_connections_on_share_key", unique: true
    t.index ["user_id", "position"], name: "index_project_connections_on_user_id_and_position"
    t.index ["user_id", "project_id"], name: "index_project_connections_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_connections_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "title", limit: 255, null: false
    t.date "started_on", null: false
    t.date "finished_on", null: false
    t.boolean "demo", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_projects_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "last_seen_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "api_token_digest"
    t.string "locale"
    t.string "region"
    t.boolean "dim_days_off", default: true, null: false
    t.index ["api_token_digest"], name: "index_users_on_api_token_digest", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "dashboards", "users"
  add_foreign_key "events", "projects"
  add_foreign_key "plan_requests", "users"
  add_foreign_key "project_connections", "projects"
  add_foreign_key "project_connections", "users"
  add_foreign_key "projects", "users", column: "owner_id"
end
