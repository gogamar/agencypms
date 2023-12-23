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

ActiveRecord::Schema[7.0].define(version: 2023_12_23_144728) do
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

  create_table "availabilities", force: :cascade do |t|
    t.date "date"
    t.integer "inventory"
    t.integer "multiplier", default: 100
    t.integer "override", default: 0
    t.bigint "vrental_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vrental_id"], name: "index_availabilities_on_vrental_id"
  end

  create_table "bathrooms", force: :cascade do |t|
    t.string "bathroom_type"
    t.bigint "vrental_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vrental_id"], name: "index_bathrooms_on_vrental_id"
  end

  create_table "bedrooms", force: :cascade do |t|
    t.string "bedroom_type"
    t.bigint "vrental_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vrental_id"], name: "index_bedrooms_on_vrental_id"
  end

  create_table "beds", force: :cascade do |t|
    t.string "bed_type"
    t.bigint "bedroom_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bedroom_id"], name: "index_beds_on_bedroom_id"
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
    t.bigint "tourist_id"
    t.string "firstname"
    t.string "lastname"
    t.boolean "locked", default: false
    t.index ["tourist_id"], name: "index_bookings_on_tourist_id"
    t.index ["vrental_id"], name: "index_bookings_on_vrental_id"
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

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "city"
    t.string "vat_number"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "post_code"
    t.string "region"
    t.string "country"
    t.string "bank_account"
    t.string "administrator"
    t.float "vat_tax"
    t.boolean "vat_tax_payer"
    t.string "realtor_number"
    t.string "language"
    t.boolean "active", default: false
    t.index ["active"], name: "index_companies_on_active", unique: true, where: "(active = true)"
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "contact_forms", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "subject"
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coupons", force: :cascade do |t|
    t.string "name"
    t.decimal "amount", precision: 10, scale: 2
    t.string "discount_type"
    t.integer "usage_limit"
    t.date "last_date"
    t.bigint "office_id", null: false
    t.index ["office_id"], name: "index_coupons_on_office_id"
  end

  create_table "coupons_vrentals", id: false, force: :cascade do |t|
    t.bigint "coupon_id", null: false
    t.bigint "vrental_id", null: false
  end

  create_table "earnings", force: :cascade do |t|
    t.string "description"
    t.decimal "discount", precision: 10, scale: 4
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vrental_id", null: false
    t.bigint "booking_id"
    t.date "date"
    t.boolean "locked", default: false
    t.bigint "statement_id"
    t.index ["booking_id"], name: "index_earnings_on_booking_id"
    t.index ["vrental_id"], name: "index_earnings_on_vrental_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.string "description"
    t.decimal "amount"
    t.string "expense_type"
    t.string "expense_number"
    t.string "expense_company"
    t.bigint "vrental_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "statement_id"
    t.index ["vrental_id"], name: "index_expenses_on_vrental_id"
  end

  create_table "features", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "highlight", default: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_features_on_company_id"
  end

  create_table "features_vrentals", id: false, force: :cascade do |t|
    t.bigint "feature_id", null: false
    t.bigint "vrental_id", null: false
  end

  create_table "image_urls", force: :cascade do |t|
    t.string "url"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vrental_id", null: false
    t.integer "photo_id"
    t.index ["photo_id"], name: "index_image_urls_on_photo_id"
    t.index ["vrental_id"], name: "index_image_urls_on_vrental_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.date "date"
    t.string "location"
    t.integer "number"
    t.bigint "vrental_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_invoices_on_company_id"
    t.index ["vrental_id"], name: "index_invoices_on_vrental_id"
  end

  create_table "offices", force: :cascade do |t|
    t.string "name"
    t.string "street"
    t.string "city"
    t.string "post_code"
    t.string "region"
    t.string "country"
    t.string "phone"
    t.string "mobile"
    t.string "email"
    t.string "website"
    t.string "opening_hours"
    t.string "manager"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "local_realtor_number"
    t.string "beds_owner_id"
    t.text "beds_key"
    t.index ["company_id"], name: "index_offices_on_company_id"
  end

  create_table "owner_bookings", force: :cascade do |t|
    t.string "status"
    t.date "checkin"
    t.date "checkout"
    t.text "note"
    t.string "beds_booking_id"
    t.bigint "vrental_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["vrental_id"], name: "index_owner_bookings_on_vrental_id"
  end

  create_table "owner_payments", force: :cascade do |t|
    t.string "description"
    t.decimal "amount"
    t.date "date"
    t.bigint "statement_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["statement_id"], name: "index_owner_payments_on_statement_id"
  end

  create_table "owners", force: :cascade do |t|
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
    t.bigint "user_id"
    t.bigint "office_id"
    t.index ["office_id"], name: "index_owners_on_office_id"
    t.index ["user_id"], name: "index_owners_on_user_id"
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

  create_table "rate_periods", force: :cascade do |t|
    t.string "name"
    t.date "firstnight"
    t.date "lastnight"
    t.integer "min_stay"
    t.string "arrival_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "rate_plan_id"
    t.integer "nights"
    t.index ["rate_plan_id"], name: "index_rate_periods_on_rate_plan_id"
  end

  create_table "rate_plans", force: :cascade do |t|
    t.string "name"
    t.date "start"
    t.date "end"
    t.integer "gen_min"
    t.string "gen_arrival"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_rate_plans_on_company_id"
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
    t.integer "nights"
    t.string "beds_rate_id"
    t.integer "max_stay", default: 365
    t.integer "min_advance", default: 0
    t.string "restriction", default: "normal"
    t.index ["vrental_id"], name: "index_rates_on_vrental_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name_ca"
    t.string "name_es"
    t.string "name_fr"
    t.string "name_en"
    t.text "description_ca"
    t.text "description_es"
    t.text "description_fr"
    t.text "description_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.string "review_id"
    t.string "client_name"
    t.string "client_location_ca"
    t.text "comment_ca"
    t.bigint "vrental_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "rating"
    t.text "comment_en"
    t.text "comment_es"
    t.text "comment_fr"
    t.string "client_location_en"
    t.string "client_location_es"
    t.string "client_location_fr"
    t.string "source"
    t.index ["vrental_id"], name: "index_reviews_on_vrental_id"
  end

  create_table "statements", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.date "date"
    t.string "location"
    t.string "ref_number"
    t.bigint "vrental_id"
    t.bigint "invoice_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_statements_on_company_id"
    t.index ["invoice_id"], name: "index_statements_on_invoice_id"
    t.index ["vrental_id"], name: "index_statements_on_vrental_id"
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
    t.bigint "user_id"
    t.index ["user_id"], name: "index_tourists_on_user_id"
  end

  create_table "towns", force: :cascade do |t|
    t.string "name"
    t.text "description_ca"
    t.text "description_es"
    t.text "description_en"
    t.text "description_fr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "region_id"
    t.decimal "city_tax", precision: 10, scale: 2
    t.text "access_text_en"
    t.text "access_text_ca"
    t.text "access_text_es"
    t.text "access_text_fr"
    t.text "house_rules_en"
    t.text "house_rules_ca"
    t.text "house_rules_es"
    t.text "house_rules_fr"
    t.index ["region_id"], name: "index_towns_on_region_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "approved", default: false, null: false
    t.bigint "company_id"
    t.integer "role"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["approved"], name: "index_users_on_approved"
    t.index ["company_id"], name: "index_users_on_company_id"
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
    t.text "owner_bookings"
    t.text "clause"
    t.string "status"
    t.integer "year"
    t.bigint "company_id"
    t.index ["company_id"], name: "index_vragreements_on_company_id"
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
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description_ca"
    t.integer "max_guests"
    t.string "status"
    t.text "description_es"
    t.text "description_fr"
    t.text "description_en"
    t.decimal "commission", precision: 10, scale: 4
    t.bigint "office_id"
    t.bigint "rate_plan_id"
    t.bigint "town_id"
    t.string "property_type"
    t.decimal "min_price", precision: 8, scale: 2
    t.float "latitude"
    t.float "longitude"
    t.boolean "featured"
    t.string "contract_type", default: "fixed_price"
    t.decimal "fixed_price_amount", precision: 10, scale: 2
    t.string "fixed_price_frequency"
    t.bigint "vrgroup_id"
    t.string "rental_term"
    t.integer "min_stay"
    t.decimal "res_fee", precision: 10, scale: 2
    t.integer "free_cancel"
    t.string "title_ca"
    t.string "title_es"
    t.string "title_fr"
    t.string "title_en"
    t.boolean "name_on_web", default: false
    t.integer "rate_master_id"
    t.decimal "rate_offset"
    t.string "rate_offset_type"
    t.string "price_per"
    t.decimal "weekly_discount"
    t.integer "min_advance", default: 0
    t.integer "unit_number"
    t.integer "availability_master_id"
    t.decimal "cleaning_fee"
    t.integer "cut_off_hour"
    t.string "checkin_start_hour"
    t.string "checkin_end_hour"
    t.string "checkout_end_hour"
    t.text "short_description_en"
    t.text "short_description_ca"
    t.text "short_description_es"
    t.text "short_description_fr"
    t.text "access_text_en"
    t.text "access_text_ca"
    t.text "access_text_es"
    t.text "access_text_fr"
    t.text "house_rules_en"
    t.text "house_rules_ca"
    t.text "house_rules_es"
    t.text "house_rules_fr"
    t.string "airbnb_listing_id"
    t.string "bookingcom_hotel_id"
    t.string "bookingcom_room_id"
    t.string "bookingcom_rate_id"
    t.index ["office_id"], name: "index_vrentals_on_office_id"
    t.index ["owner_id"], name: "index_vrentals_on_owner_id"
    t.index ["rate_plan_id"], name: "index_vrentals_on_rate_plan_id"
    t.index ["town_id"], name: "index_vrentals_on_town_id"
    t.index ["vrgroup_id"], name: "index_vrentals_on_vrgroup_id"
  end

  create_table "vrentaltemplates", force: :cascade do |t|
    t.string "title"
    t.string "language"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "public", default: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_vrentaltemplates_on_company_id"
  end

  create_table "vrgroups", force: :cascade do |t|
    t.string "name"
    t.bigint "office_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_vrgroups_on_office_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "availabilities", "vrentals"
  add_foreign_key "bathrooms", "vrentals"
  add_foreign_key "bedrooms", "vrentals"
  add_foreign_key "beds", "bedrooms"
  add_foreign_key "bookings", "tourists"
  add_foreign_key "bookings", "vrentals"
  add_foreign_key "charges", "bookings"
  add_foreign_key "companies", "users"
  add_foreign_key "coupons", "offices"
  add_foreign_key "earnings", "bookings"
  add_foreign_key "earnings", "vrentals"
  add_foreign_key "expenses", "vrentals"
  add_foreign_key "features", "companies"
  add_foreign_key "image_urls", "vrentals"
  add_foreign_key "invoices", "companies"
  add_foreign_key "invoices", "vrentals"
  add_foreign_key "offices", "companies"
  add_foreign_key "owner_bookings", "vrentals"
  add_foreign_key "owner_payments", "statements"
  add_foreign_key "owners", "users"
  add_foreign_key "payments", "bookings"
  add_foreign_key "rate_periods", "rate_plans"
  add_foreign_key "rate_plans", "companies"
  add_foreign_key "rates", "vrentals"
  add_foreign_key "reviews", "vrentals"
  add_foreign_key "statements", "companies"
  add_foreign_key "statements", "invoices"
  add_foreign_key "statements", "vrentals"
  add_foreign_key "tasks", "users"
  add_foreign_key "tourists", "users"
  add_foreign_key "towns", "regions"
  add_foreign_key "users", "companies"
  add_foreign_key "vragreements", "companies"
  add_foreign_key "vragreements", "vrentals"
  add_foreign_key "vragreements", "vrentaltemplates"
  add_foreign_key "vrentals", "offices"
  add_foreign_key "vrentals", "owners"
  add_foreign_key "vrentals", "rate_plans"
  add_foreign_key "vrentals", "towns"
  add_foreign_key "vrentals", "vrentals", column: "availability_master_id"
  add_foreign_key "vrentals", "vrentals", column: "rate_master_id"
  add_foreign_key "vrentals", "vrgroups"
  add_foreign_key "vrentaltemplates", "companies"
  add_foreign_key "vrgroups", "offices"
end
