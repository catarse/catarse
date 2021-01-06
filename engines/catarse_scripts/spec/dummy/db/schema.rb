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

ActiveRecord::Schema.define(version: 2020_11_27_125316) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "scripts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.bigint "executor_id"
    t.integer "status", null: false
    t.string "title", limit: 128, null: false
    t.string "description", limit: 512
    t.text "code", null: false
    t.string "ticket_url", limit: 512
    t.string "class_name", limit: 128, null: false
    t.string "tags", default: [], array: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_scripts_on_creator_id"
    t.index ["executor_id"], name: "index_scripts_on_executor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "scripts", "users", column: "creator_id"
  add_foreign_key "scripts", "users", column: "executor_id"
end
