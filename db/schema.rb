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

ActiveRecord::Schema.define(:version => 20111126220300) do

  create_table "measures", :force => true do |t|
    t.float    "speed"
    t.float    "direction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "station_id"
    t.float    "max_wind_speed"
    t.float    "min_wind_speed"
    t.float    "temperature"
  end

  create_table "stations", :force => true do |t|
    t.string   "name"
    t.string   "hw_id"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "timezone"
  end

end
