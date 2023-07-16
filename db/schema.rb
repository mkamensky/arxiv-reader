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

ActiveRecord::Schema[7.0].define(version: 2023_07_16_050339) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.string "name", null: false
    t.string "arxiv"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arxiv"], name: "index_authors_on_arxiv", unique: true
  end

  create_table "authorships", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.bigint "paper_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_authorships_on_author_id"
    t.index ["paper_id"], name: "index_authorships_on_paper_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "arxiv"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "subject_id", null: false
    t.index ["arxiv"], name: "index_categories_on_arxiv", unique: true
    t.index ["subject_id"], name: "index_categories_on_subject_id"
  end

  create_table "categorisations", force: :cascade do |t|
    t.bigint "paper_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorisations_on_category_id"
    t.index ["paper_id", "category_id"], name: "index_categorisations_on_paper_id_and_category_id", unique: true
    t.index ["paper_id"], name: "index_categorisations_on_paper_id"
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

  create_table "subjects", force: :cascade do |t|
    t.string "title"
    t.string "arxiv", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arxiv"], name: "index_subjects_on_arxiv", unique: true
  end

  add_foreign_key "authorships", "authors"
  add_foreign_key "authorships", "papers"
  add_foreign_key "categories", "subjects"
  add_foreign_key "categorisations", "categories"
  add_foreign_key "categorisations", "papers"
  add_foreign_key "papers", "categories"
end
