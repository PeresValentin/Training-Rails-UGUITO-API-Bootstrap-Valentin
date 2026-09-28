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

ActiveRecord::Schema.define(version: 2026_09_23_130231) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "async_request_jobs", force: :cascade do |t|
    t.string "worker"
    t.integer "status"
    t.integer "status_code"
    t.text "response"
    t.string "uid"
    t.text "params"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_async_request_jobs_on_status"
    t.index ["uid"], name: "index_async_request_jobs_on_uid", unique: true
  end

  create_table "books", force: :cascade do |t|
    t.bigint "utility_id"
    t.bigint "user_id"
    t.string "genre", null: false
    t.string "author", null: false
    t.string "image", null: false
    t.string "title", null: false
    t.string "publisher", null: false
    t.string "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_books_on_user_id"
    t.index ["utility_id"], name: "index_books_on_utility_id"
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "notes", force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.integer "note_type", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name", default: ""
    t.string "last_name", default: ""
    t.string "document_number", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "utility_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["utility_id"], name: "index_users_on_utility_id"
  end

  create_table "utilities", force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.integer "code"
    t.string "base_url"
    t.string "external_api_key"
    t.string "external_api_secret"
    t.string "external_api_access_token"
    t.datetime "external_api_access_token_expiration"
    t.jsonb "integration_urls", default: {}
    t.jsonb "jsonb", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "books", "users"
  add_foreign_key "books", "utilities"
  add_foreign_key "notes", "users"
  add_foreign_key "users", "utilities"
end
