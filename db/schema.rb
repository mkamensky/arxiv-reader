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

ActiveRecord::Schema[7.0].define(version: 2023_07_15_150048) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "arxiv"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arxiv"], name: "index_categories_on_arxiv", unique: true
  end

  create_table "papers", force: :cascade do |t|
    t.string "arxiv"
    t.string "title"
    t.text "abstract"
    t.string "version"
    t.date "submitted", null: false
    t.date "revised"
    t.bigint "category_id", null: false
    t.text "comment"
    t.string "abs", null: false
    t.string "pdf"
    t.string "tags", default: [], array: true
    t.string "journal_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arxiv", "version"], name: "index_papers_on_arxiv_and_version", unique: true
    t.index ["arxiv"], name: "index_papers_on_arxiv"
    t.index ["category_id"], name: "index_papers_on_category_id"
    t.index ["submitted"], name: "index_papers_on_submitted"
    t.index ["tags"], name: "index_papers_on_tags"
  end

  add_foreign_key "papers", "categories"
end
