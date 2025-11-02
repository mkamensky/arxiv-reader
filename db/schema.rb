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

ActiveRecord::Schema[8.1].define(version: 2025_10_21_065800) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "authors", force: :cascade do |t|
    t.string "arxiv"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "name_variants", default: [], array: true
    t.virtual "searchable", type: :tsvector, as: "(setweight(to_tsvector('english'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::\"char\") || setweight(array_to_tsvector((name_variants)::text[]), 'B'::\"char\"))", stored: true
    t.datetime "updated_at", null: false
    t.index ["arxiv"], name: "index_authors_on_arxiv", unique: true
    t.index ["name_variants"], name: "index_authors_on_name_variants"
    t.index ["searchable"], name: "index_authors_on_searchable", using: :gin
  end

  create_table "authorships", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.bigint "paper_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_authorships_on_author_id"
    t.index ["paper_id"], name: "index_authorships_on_paper_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "paper_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["paper_id", "user_id"], name: "index_bookmarks_on_paper_id_and_user_id", unique: true
    t.index ["paper_id"], name: "index_bookmarks_on_paper_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "arxiv"
    t.datetime "created_at", null: false
    t.bigint "subject_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["arxiv"], name: "index_categories_on_arxiv", unique: true
    t.index ["subject_id"], name: "index_categories_on_subject_id"
  end

  create_table "categorisations", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.bigint "paper_id", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_categorisations_on_category_id"
    t.index ["paper_id", "category_id"], name: "index_categorisations_on_paper_id_and_category_id", unique: true
    t.index ["paper_id"], name: "index_categorisations_on_paper_id"
  end

  create_table "followships", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["author_id", "user_id"], name: "index_followships_on_author_id_and_user_id", unique: true
    t.index ["author_id"], name: "index_followships_on_author_id"
    t.index ["user_id"], name: "index_followships_on_user_id"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "hidden_papers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "paper_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["paper_id", "user_id"], name: "index_hidden_papers_on_paper_id_and_user_id", unique: true
    t.index ["paper_id"], name: "index_hidden_papers_on_paper_id"
    t.index ["user_id"], name: "index_hidden_papers_on_user_id"
  end

  create_table "papers", force: :cascade do |t|
    t.string "abs", null: false
    t.text "abstract"
    t.string "arxiv"
    t.bigint "category_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.string "journal_ref"
    t.string "pdf"
    t.string "primary", default: [], array: true
    t.date "revised"
    t.virtual "searchable", type: :tsvector, as: "((setweight(to_tsvector('english'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::\"char\") || setweight(to_tsvector('english'::regconfig, COALESCE(abstract, ''::text)), 'B'::\"char\")) || setweight(to_tsvector('english'::regconfig, COALESCE(comment, ''::text)), 'C'::\"char\"))", stored: true
    t.string "secondary", default: [], array: true
    t.date "submitted", null: false
    t.string "tags", default: [], array: true
    t.string "title"
    t.datetime "updated_at", null: false
    t.string "version"
    t.index ["arxiv", "version"], name: "index_papers_on_arxiv_and_version", unique: true
    t.index ["arxiv"], name: "index_papers_on_arxiv"
    t.index ["category_id"], name: "index_papers_on_category_id"
    t.index ["primary"], name: "index_papers_on_primary", using: :gin
    t.index ["searchable"], name: "index_papers_on_searchable", using: :gin
    t.index ["secondary"], name: "index_papers_on_secondary", using: :gin
    t.index ["submitted"], name: "index_papers_on_submitted"
    t.index ["tags"], name: "index_papers_on_tags"
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", null: false
    t.bigint "searchable_id"
    t.string "searchable_type"
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "recommendations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "paper_id", null: false
    t.float "score", default: 1.0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["paper_id", "user_id"], name: "index_recommendations_on_paper_id_and_user_id", unique: true
    t.index ["paper_id"], name: "index_recommendations_on_paper_id"
    t.index ["user_id"], name: "index_recommendations_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "arxiv", null: false
    t.datetime "created_at", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["arxiv"], name: "index_subjects_on_arxiv", unique: true
  end

  create_table "usercats", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["category_id", "user_id"], name: "index_usercats_on_category_id_and_user_id", unique: true
    t.index ["category_id"], name: "index_usercats_on_category_id"
    t.index ["user_id"], name: "index_usercats_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "author_id"
    t.string "avatar"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "github"
    t.string "name", default: ""
    t.string "orcid"
    t.string "password_digest"
    t.jsonb "prefs", default: {}, null: false
    t.bigint "subject_id"
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_users_on_author_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github"], name: "index_users_on_github", nulls_not_distinct: true
    t.index ["orcid"], name: "index_users_on_orcid", nulls_not_distinct: true
    t.index ["subject_id"], name: "index_users_on_subject_id"
  end

  add_foreign_key "authorships", "authors"
  add_foreign_key "authorships", "papers"
  add_foreign_key "bookmarks", "papers"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "categories", "subjects"
  add_foreign_key "categorisations", "categories"
  add_foreign_key "categorisations", "papers"
  add_foreign_key "followships", "authors"
  add_foreign_key "followships", "users"
  add_foreign_key "hidden_papers", "papers"
  add_foreign_key "hidden_papers", "users"
  add_foreign_key "papers", "categories"
  add_foreign_key "recommendations", "papers"
  add_foreign_key "recommendations", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "usercats", "categories"
  add_foreign_key "usercats", "users"
  add_foreign_key "users", "authors"
  add_foreign_key "users", "subjects"
end
