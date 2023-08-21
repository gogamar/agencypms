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

ActiveRecord::Schema[7.0].define(version: 2023_08_21_135935) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

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

  create_table "blocks", force: :cascade do |t|
    t.string "title_en"
    t.string "title_ca"
    t.string "title_es"
    t.string "title_fr"
    t.string "subtitle_en"
    t.string "subtitle_ca"
    t.string "subtitle_es"
    t.string "subtitle_fr"
    t.text "content_en"
    t.text "content_ca"
    t.text "content_es"
    t.text "content_fr"
    t.string "button_en"
    t.string "button_ca"
    t.string "button_es"
    t.string "button_fr"
    t.bigint "page_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["page_id"], name: "index_blocks_on_page_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.string "status"
    t.date "checkin"
    t.date "checkout"
    t.integer "nights"
    t.integer "adults"
    t.integer "children"
    t.string "referrer"
    t.decimal "price", precision: 10, scale: 2
    t.decimal "commission", precision: 10, scale: 2
    t.string "beds_booking_id"
    t.bigint "vrental_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tourist_id", null: false
    t.index ["tourist_id"], name: "index_bookings_on_tourist_id"
    t.index ["vrental_id"], name: "index_bookings_on_vrental_id"
  end

  create_table "buyers", force: :cascade do |t|
    t.string "fullname"
    t.string "address"
    t.string "document"
    t.string "account"
    t.string "language"
    t.string "phone"
    t.string "email"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_bank"
    t.index ["user_id"], name: "index_buyers_on_user_id"
  end

  create_table "charges", force: :cascade do |t|
    t.string "description"
    t.integer "quantity"
    t.decimal "price"
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "beds_id"
    t.string "charge_type"
    t.index ["booking_id"], name: "index_charges_on_booking_id"
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

  create_table "comtypes", force: :cascade do |t|
    t.string "company_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_comtypes_on_user_id"
  end

  create_table "contracts", force: :cascade do |t|
    t.float "price"
    t.text "contentarea"
    t.string "pricetext"
    t.string "place"
    t.date "signdate"
    t.bigint "realestate_id", null: false
    t.bigint "rstemplate_id"
    t.bigint "buyer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "down_payment"
    t.string "down_payment_text"
    t.float "dp_part1"
    t.float "dp_part2"
    t.string "dp_part1_text"
    t.string "dp_part2_text"
    t.date "signdate_notary"
    t.string "min_notice"
    t.string "court"
    t.index ["buyer_id"], name: "index_contracts_on_buyer_id"
    t.index ["realestate_id"], name: "index_contracts_on_realestate_id"
    t.index ["rstemplate_id"], name: "index_contracts_on_rstemplate_id"
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
    t.string "phone"
    t.string "email"
    t.index ["user_id"], name: "index_owners_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.string "title_en"
    t.string "title_ca"
    t.string "title_es"
    t.string "title_fr"
    t.string "page_type"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pages_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "description"
    t.integer "quantity"
    t.decimal "price"
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "beds_id"
    t.index ["booking_id"], name: "index_payments_on_booking_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "businessname"
    t.string "companyname"
    t.string "address"
    t.string "vat"
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
    t.bigint "comtype_id"
    t.string "aicat"
    t.string "api"
    t.index ["comtype_id"], name: "index_profiles_on_comtype_id"
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
    t.boolean "sent_to_beds"
    t.datetime "date_sent_to_beds", precision: nil
    t.index ["vrental_id"], name: "index_rates_on_vrental_id"
  end

  create_table "realestates", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "cadastre"
    t.string "energy"
    t.text "description"
    t.string "status"
    t.bigint "user_id", null: false
    t.bigint "seller_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "registrar"
    t.string "volume"
    t.string "book"
    t.string "sheet"
    t.string "registry"
    t.string "entry"
    t.text "charges"
    t.string "habitability"
    t.date "hab_date"
    t.string "registry_code"
    t.string "protocol"
    t.date "deed_date"
    t.string "notary"
    t.string "notary_fullname"
    t.string "mortgage_bank"
    t.float "mortgage_amount"
    t.index ["seller_id"], name: "index_realestates_on_seller_id"
    t.index ["user_id"], name: "index_realestates_on_user_id"
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
    t.string "status"
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
    t.boolean "public", default: false
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
    t.string "phone"
    t.string "email"
    t.index ["user_id"], name: "index_renters_on_user_id"
  end

  create_table "rstemplates", force: :cascade do |t|
    t.string "title"
    t.string "language"
    t.text "text"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: false
    t.index ["user_id"], name: "index_rstemplates_on_user_id"
  end

  create_table "sellers", force: :cascade do |t|
    t.string "fullname"
    t.string "address"
    t.string "document"
    t.string "account"
    t.string "language"
    t.string "phone"
    t.string "email"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_bank"
    t.index ["user_id"], name: "index_sellers_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.time "start_time"
    t.date "start_date"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "tourists", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "phone"
    t.string "email"
    t.string "address"
    t.string "country_code"
    t.string "country"
    t.string "document"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.boolean "approved", default: false, null: false
    t.index ["approved"], name: "index_users_on_approved"
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
    t.string "status"
    t.integer "year"
    t.index ["vrental_id"], name: "index_vragreements_on_vrental_id"
    t.index ["vrentaltemplate_id"], name: "index_vragreements_on_vrentaltemplate_id"
  end

  create_table "vrentals", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "licence"
    t.string "cadastre"
    t.string "habitability"
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
    t.decimal "commission", precision: 10, scale: 2
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
    t.boolean "public", default: false
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
  add_foreign_key "blocks", "pages"
  add_foreign_key "bookings", "tourists"
  add_foreign_key "bookings", "vrentals"
  add_foreign_key "buyers", "users"
  add_foreign_key "charges", "bookings"
  add_foreign_key "comtypes", "users"
  add_foreign_key "contracts", "buyers"
  add_foreign_key "contracts", "realestates"
  add_foreign_key "contracts", "rstemplates"
  add_foreign_key "features", "users"
  add_foreign_key "owners", "users"
  add_foreign_key "pages", "users"
  add_foreign_key "payments", "bookings"
  add_foreign_key "profiles", "comtypes"
  add_foreign_key "profiles", "users"
  add_foreign_key "rates", "vrentals"
  add_foreign_key "realestates", "sellers"
  add_foreign_key "realestates", "users"
  add_foreign_key "rentals", "owners"
  add_foreign_key "rentals", "users"
  add_foreign_key "rentaltemplates", "users"
  add_foreign_key "renters", "users"
  add_foreign_key "rstemplates", "users"
  add_foreign_key "sellers", "users"
  add_foreign_key "tasks", "users"
  add_foreign_key "vragreements", "vrentals"
  add_foreign_key "vragreements", "vrentaltemplates"
  add_foreign_key "vrentals", "users"
  add_foreign_key "vrentals", "vrowners"
  add_foreign_key "vrentaltemplates", "users"
  add_foreign_key "vrowners", "users"
end
