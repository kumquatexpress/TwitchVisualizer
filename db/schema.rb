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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140501044953) do

  create_table "channels", primary_key: "channel_id", force: true do |t|
    t.string   "name"
    t.string   "display_name"
    t.integer  "followers"
    t.integer  "views"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "channels", ["channel_id"], name: "index_channels_on_channel_id", using: :btree

  create_table "channels_users", id: false, force: true do |t|
    t.integer  "user_id"
    t.integer  "channel_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "channels_users", ["channel_id"], name: "index_channels_users_on_channel_id", using: :btree
  add_index "channels_users", ["user_id"], name: "index_channels_users_on_user_id", using: :btree

  create_table "users", primary_key: "user_id", force: true do |t|
    t.string   "name"
    t.string   "display_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["user_id"], name: "index_users_on_user_id", using: :btree

end
