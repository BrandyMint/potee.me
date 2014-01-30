# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140130183109) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "authentications", :force => true do |t|
    t.string  "provider", :null => false
    t.string  "uid",      :null => false
    t.integer "user_id",  :null => false
  end

  create_table "dashboards", :force => true do |t|
    t.integer  "pixels_per_day", :default => 145
    t.date     "current_date"
    t.integer  "user_id",                         :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "dashboards", ["user_id"], :name => "index_dashboards_on_user_id", :unique => true

  create_table "events", :force => true do |t|
    t.string   "title",      :null => false
    t.integer  "project_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.date     "date",       :null => false
    t.time     "time",       :null => false
  end

  add_index "events", ["project_id"], :name => "index_events_on_project_id"

  create_table "project_connections", :force => true do |t|
    t.integer  "project_id",                 :null => false
    t.integer  "user_id",                    :null => false
    t.integer  "position",    :default => 0, :null => false
    t.string   "share_key",                  :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "color_index", :default => 0, :null => false
  end

  add_index "project_connections", ["project_id"], :name => "index_project_connections_on_project_id"
  add_index "project_connections", ["share_key"], :name => "index_project_connections_on_share_key", :unique => true
  add_index "project_connections", ["user_id", "position"], :name => "index_project_connections_on_user_id_and_position"
  add_index "project_connections", ["user_id", "project_id"], :name => "index_project_connections_on_user_id_and_project_id", :unique => true

  create_table "projects", :force => true do |t|
    t.string   "title",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.date     "started_at", :null => false
    t.date     "finish_at"
    t.integer  "owner_id"
  end

  add_index "projects", ["title"], :name => "index_projects_on_title"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "last_sign_in_at"
    t.string   "avatar"
  end

end
