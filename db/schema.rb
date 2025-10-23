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

ActiveRecord::Schema[8.1].define(version: 2025_10_23_154504) do
  create_table "cells", force: :cascade do |t|
    t.string "column_key", null: false
    t.datetime "created_at", null: false
    t.string "data_type", default: "text"
    t.text "formula"
    t.json "metadata", default: {}
    t.integer "row_id", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["row_id", "column_key"], name: "index_cells_on_row_id_and_column_key", unique: true
    t.index ["row_id"], name: "index_cells_on_row_id"
  end

  create_table "collaborators", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "permission", default: "view"
    t.integer "spreadsheet_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["spreadsheet_id", "email"], name: "index_collaborators_on_spreadsheet_id_and_email", unique: true
    t.index ["spreadsheet_id", "user_id"], name: "index_collaborators_on_spreadsheet_id_and_user_id", unique: true
    t.index ["spreadsheet_id"], name: "index_collaborators_on_spreadsheet_id"
  end

  create_table "rows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.json "data", default: {}
    t.integer "position", null: false
    t.integer "sheet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sheet_id", "position"], name: "index_rows_on_sheet_id_and_position"
    t.index ["sheet_id"], name: "index_rows_on_sheet_id"
  end

  create_table "sheets", force: :cascade do |t|
    t.json "column_definitions", default: []
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.json "settings", default: {}
    t.integer "spreadsheet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["spreadsheet_id", "position"], name: "index_sheets_on_spreadsheet_id_and_position"
    t.index ["spreadsheet_id"], name: "index_sheets_on_spreadsheet_id"
  end

  create_table "spreadsheets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "owner_id"
    t.boolean "public", default: false
    t.json "settings", default: {}
    t.string "share_token"
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_spreadsheets_on_owner_id"
    t.index ["share_token"], name: "index_spreadsheets_on_share_token", unique: true
  end

  add_foreign_key "cells", "rows"
  add_foreign_key "collaborators", "spreadsheets"
  add_foreign_key "rows", "sheets"
  add_foreign_key "sheets", "spreadsheets"
end
