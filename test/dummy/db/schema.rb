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

ActiveRecord::Schema.define(:version => 20121227170033) do

  create_table "freebase_model_relations", :force => true do |t|
    t.string   "subject_type"
    t.integer  "subject_id"
    t.string   "property"
    t.string   "object_type"
    t.integer  "object_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "freebase_model_relations", ["subject_type", "subject_id", "property", "object_type", "object_id"], :name => "freebase_topic_relations_triple"

  create_table "freebase_topic_relations", :force => true do |t|
    t.string   "subject_type"
    t.integer  "subject_id"
    t.string   "property"
    t.integer  "freebase_topic_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "freebase_topic_relations", ["freebase_topic_id"], :name => "index_freebase_topic_relations_on_freebase_topic_id"
  add_index "freebase_topic_relations", ["subject_type", "subject_id", "property"], :name => "subject_property"

  create_table "freebase_topics", :force => true do |t|
    t.string   "freebase_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "freebase_topics", ["freebase_id"], :name => "index_freebase_topics_on_freebase_id"

  create_table "music_artists", :force => true do |t|
    t.string   "freebase_id"
    t.string   "name"
    t.text     "description"
    t.datetime "active_start"
    t.datetime "active_end"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "music_artists", ["freebase_id"], :name => "index_music_artists_on_freebase_id"

  create_table "us_states", :force => true do |t|
    t.string   "freebase_id"
    t.string   "name"
    t.string   "area"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "us_states", ["freebase_id"], :name => "index_us_states_on_freebase_id"

end
