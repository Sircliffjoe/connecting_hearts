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

ActiveRecord::Schema[8.1].define(version: 2026_07_29_200400) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contact_inquiries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.string "name", null: false
    t.string "status", default: "pending"
    t.string "subject", null: false
    t.datetime "updated_at", null: false
  end

  create_table "donations", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "NGN"
    t.string "donor_email", null: false
    t.string "donor_name"
    t.string "payment_reference", null: false
    t.string "purpose", null: false
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
  end

  create_table "event_registrations", force: :cascade do |t|
    t.string "attendance_type", default: "in_person"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.bigint "event_id"
    t.string "full_name", null: false
    t.string "phone"
    t.string "status", default: "confirmed"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_event_registrations_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "edition_number"
    t.datetime "event_date"
    t.boolean "featured", default: false
    t.string "image_url"
    t.string "location"
    t.string "registration_link"
    t.string "theme"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "partnership_inquiries", force: :cascade do |t|
    t.string "contact_person", null: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.string "organization_name", null: false
    t.string "partnership_type", null: false
    t.string "phone"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
  end

  create_table "resources", force: :cascade do |t|
    t.string "category", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.string "external_link"
    t.string "file_url"
    t.boolean "published", default: true
    t.string "resource_type", null: false
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stories", force: :cascade do |t|
    t.text "body", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.boolean "featured", default: false
    t.string "image_url"
    t.boolean "published", default: true
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
  end

  create_table "support_requests", force: :cascade do |t|
    t.boolean "consent_given", default: false
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.text "notes"
    t.string "phone"
    t.string "preferred_contact_method", default: "email"
    t.bigint "reviewed_by_id"
    t.string "session_format", default: "online"
    t.text "situation_description", null: false
    t.string "status", default: "pending"
    t.string "support_category", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewed_by_id"], name: "index_support_requests_on_reviewed_by_id"
  end

  create_table "testimonials", force: :cascade do |t|
    t.boolean "approved", default: true
    t.string "author_name", null: false
    t.datetime "created_at", null: false
    t.string "edition_title"
    t.boolean "featured", default: false
    t.text "quote", null: false
    t.string "relationship_status"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "image_url"
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "role", default: "admin", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "volunteer_applications", force: :cascade do |t|
    t.string "availability"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.text "notes"
    t.string "phone"
    t.string "role_interest", null: false
    t.text "skills"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "event_registrations", "events"
  add_foreign_key "support_requests", "users", column: "reviewed_by_id"
end
