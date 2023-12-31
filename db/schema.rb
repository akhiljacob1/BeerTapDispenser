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

ActiveRecord::Schema[7.0].define(version: 2023_08_20_112924) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dispensers", force: :cascade do |t|
    t.float "flow_volume", null: false
    t.float "cost_per_litre", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tap_logs", force: :cascade do |t|
    t.integer "event_type", default: 0, null: false
    t.bigint "dispenser_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispenser_id"], name: "index_tap_logs_on_dispenser_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.integer "total_time"
    t.float "total_volume"
    t.float "total_cost"
    t.bigint "dispenser_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispenser_id"], name: "index_transactions_on_dispenser_id"
  end

  add_foreign_key "tap_logs", "dispensers"
  add_foreign_key "transactions", "dispensers"
end
