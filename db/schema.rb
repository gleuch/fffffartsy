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

ActiveRecord::Schema.define(version: 20121202213100) do

  create_table "art_pieces", force: true do |t|
    t.string   "slug"
    t.integer  "format",     default: 0
    t.string   "url"
    t.string   "title"
    t.string   "artist"
    t.string   "media"
    t.string   "dimensions"
    t.integer  "year"
    t.integer  "width"
    t.integer  "height"
    t.float    "scale",      default: 1.0
    t.integer  "gallery",    default: 0
    t.integer  "frame",      default: 0
    t.integer  "audience",   default: 0
    t.boolean  "active",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
