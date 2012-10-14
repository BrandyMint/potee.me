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

ActiveRecord::Schema.define(:version => 20121014155354) do

  create_table "authentications", :force => true do |t|
    t.string  "provider", :null => false
    t.string  "uid",      :null => false
    t.integer "user_id",  :null => false
  end

  create_table "events", :force => true do |t|
    t.string   "title",      :null => false
    t.integer  "project_id", :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.date     "date",       :null => false
    t.time     "time",       :null => false
  end

  add_index "events", ["project_id"], :name => "index_events_on_project_id"

  create_table "projects", :force => true do |t|
    t.string   "title",                      :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.date     "started_at",                 :null => false
    t.date     "finish_at"
    t.integer  "color_index", :default => 0, :null => false
    t.integer  "user_id",                    :null => false
  end

  add_index "projects", ["title"], :name => "index_projects_on_title"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
