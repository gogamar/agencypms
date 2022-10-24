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

ActiveRecord::Schema[7.0].define(version: 2022_10_24_134959) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agreements", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.float "price"
    t.float "deposit"
    t.text "contentarea"
    t.string "duration"
    t.string "pricetext"
    t.string "place"
    t.date "signdate"
    t.bigint "renter_id"
    t.bigint "rentaltemplate_id"
    t.bigint "rental_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rental_id"], name: "index_agreements_on_rental_id"
    t.index ["rentaltemplate_id"], name: "index_agreements_on_rentaltemplate_id"
    t.index ["renter_id"], name: "index_agreements_on_renter_id"
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "data_fingerprint"
    t.string "type", limit: 30
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "features", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "beds_room_id"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_features_on_user_id"
  end

  create_table "features_vrentals", id: false, force: :cascade do |t|
    t.bigint "feature_id", null: false
    t.bigint "vrental_id", null: false
  end

  create_table "owners", force: :cascade do |t|
    t.string "fullname"
    t.string "address"
    t.string "document"
    t.string "account"
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_owners_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "businessname"
    t.string "companyname"
    t.string "address"
    t.string "vat"
    t.string "companytype"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "officeaddress"
    t.string "officezip"
    t.string "officecity"
    t.string "companyzip"
    t.string "companycity"
    t.string "officephone"
    t.string "companyphone"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "rates", force: :cascade do |t|
    t.float "pricenight"
    t.string "beds_room_id"
    t.date "firstnight"
    t.date "lastnight"
    t.integer "min_stay"
    t.string "arrival_day"
    t.float "priceweek"
    t.bigint "vrental_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vrental_id"], name: "index_rates_on_vrental_id"
  end

  create_table "rentals", force: :cascade do |t|
    t.string "address"
    t.string "cadastre"
    t.string "energy"
    t.string "city"
    t.text "description"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["owner_id"], name: "index_rentals_on_owner_id"
    t.index ["user_id"], name: "index_rentals_on_user_id"
  end

  create_table "rentaltemplates", force: :cascade do |t|
    t.string "title"
    t.string "language"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_rentaltemplates_on_user_id"
  end

  create_table "renters", force: :cascade do |t|
    t.string "fullname"
    t.string "address"
    t.string "document"
    t.string "account"
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_renters_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vragreements", force: :cascade do |t|
    t.date "signdate"
    t.string "place"
    t.date "start_date"
    t.date "end_date"
    t.bigint "vrentaltemplate_id"
    t.bigint "vrental_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "vrowner_bookings"
    t.text "clause"
    t.index ["vrental_id"], name: "index_vragreements_on_vrental_id"
    t.index ["vrentaltemplate_id"], name: "index_vragreements_on_vrentaltemplate_id"
  end

  create_table "vrentals", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "licence"
    t.string "cadastre"
    t.string "habitability"
    t.string "commission"
    t.string "beds_room_id"
    t.string "beds_prop_id"
    t.string "prop_key"
    t.bigint "vrowner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.integer "max_guests"
    t.string "status"
    t.text "description_es"
    t.text "description_fr"
    t.text "description_en"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_vrentals_on_user_id"
    t.index ["vrowner_id"], name: "index_vrentals_on_vrowner_id"
  end

  create_table "vrentaltemplates", force: :cascade do |t|
    t.string "title"
    t.string "language"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_vrentaltemplates_on_user_id"
  end

  create_table "vrowners", force: :cascade do |t|
    t.string "fullname"
    t.string "language"
    t.string "document"
    t.string "address"
    t.string "email"
    t.string "phone"
    t.string "account"
    t.string "beds_room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_vrowners_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agreements", "rentals"
  add_foreign_key "agreements", "rentaltemplates"
  add_foreign_key "agreements", "renters"
  add_foreign_key "features", "users"
  add_foreign_key "owners", "users"
  add_foreign_key "profiles", "users"
  add_foreign_key "rates", "vrentals"
  add_foreign_key "rentals", "owners"
  add_foreign_key "rentals", "users"
  add_foreign_key "rentaltemplates", "users"
  add_foreign_key "renters", "users"
  add_foreign_key "vragreements", "vrentals"
  add_foreign_key "vragreements", "vrentaltemplates"
  add_foreign_key "vrentals", "users"
  add_foreign_key "vrentals", "vrowners"
  add_foreign_key "vrentaltemplates", "users"
  add_foreign_key "vrowners", "users"
end
