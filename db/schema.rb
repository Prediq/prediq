# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141119165831) do

  create_table "admins", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["authentication_token"], name: "index_admins_on_authentication_token", unique: true, using: :btree
  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["last_name"], name: "index_admins_on_last_name", using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "admins_roles", id: false, force: true do |t|
    t.integer "admin_id"
    t.integer "role_id"
  end

  add_index "admins_roles", ["admin_id", "role_id"], name: "index_admins_roles_on_admin_id_and_role_id", using: :btree

  create_table "api_address", primary_key: "address_id", force: true do |t|
    t.integer "customer_id",                                         null: false
    t.string  "firstname",                   limit: 32,              null: false
    t.string  "lastname",                    limit: 32,              null: false
    t.string  "company",                     limit: 32,              null: false
    t.string  "company_id",                  limit: 32,              null: false
    t.string  "tax_id",                      limit: 32,              null: false
    t.string  "address_1",                   limit: 128,             null: false
    t.string  "address_2",                   limit: 128,             null: false
    t.string  "city",                        limit: 128,             null: false
    t.string  "postcode",                    limit: 10,              null: false
    t.integer "country_id",                              default: 0, null: false
    t.integer "zone_id",                                 default: 0, null: false
    t.integer "weather_station_id",                                  null: false
    t.string  "weather_station_code",        limit: 16,              null: false
    t.float   "distance_to_weather_station", limit: 24,              null: false
    t.float   "lat",                         limit: 53,              null: false
    t.float   "lon",                         limit: 53,              null: false
  end

  add_index "api_address", ["customer_id"], name: "customer_id", using: :btree

  create_table "api_address_annotation", primary_key: "api_address_annotation_id", force: true do |t|
    t.integer  "address_id",                                null: false
    t.datetime "event_date",                                null: false
    t.integer  "address_annotation_event_id",               null: false
    t.string   "event_description",           limit: 10000, null: false
  end

  add_index "api_address_annotation", ["address_annotation_event_id"], name: "address_annotation_event_id", using: :btree
  add_index "api_address_annotation", ["address_id"], name: "address_id", using: :btree

  create_table "api_address_annotation_event", primary_key: "address_annotation_event_id", force: true do |t|
    t.string "event", null: false
  end

  create_table "api_affiliate", primary_key: "affiliate_id", force: true do |t|
    t.string   "firstname",           limit: 32,                                        null: false
    t.string   "lastname",            limit: 32,                                        null: false
    t.string   "email",               limit: 96,                                        null: false
    t.string   "telephone",           limit: 32,                                        null: false
    t.string   "fax",                 limit: 32,                                        null: false
    t.string   "password",            limit: 40,                                        null: false
    t.string   "salt",                limit: 9,                                         null: false
    t.string   "company",             limit: 32,                                        null: false
    t.string   "website",                                                               null: false
    t.string   "address_1",           limit: 128,                                       null: false
    t.string   "address_2",           limit: 128,                                       null: false
    t.string   "city",                limit: 128,                                       null: false
    t.string   "postcode",            limit: 10,                                        null: false
    t.integer  "country_id",                                                            null: false
    t.integer  "zone_id",                                                               null: false
    t.string   "code",                limit: 64,                                        null: false
    t.decimal  "commission",                      precision: 4, scale: 2, default: 0.0, null: false
    t.string   "tax",                 limit: 64,                                        null: false
    t.string   "payment",             limit: 6,                                         null: false
    t.string   "cheque",              limit: 100,                                       null: false
    t.string   "paypal",              limit: 64,                                        null: false
    t.string   "bank_name",           limit: 64,                                        null: false
    t.string   "bank_branch_number",  limit: 64,                                        null: false
    t.string   "bank_swift_code",     limit: 64,                                        null: false
    t.string   "bank_account_name",   limit: 64,                                        null: false
    t.string   "bank_account_number", limit: 64,                                        null: false
    t.string   "ip",                  limit: 40,                                        null: false
    t.boolean  "status",                                                                null: false
    t.boolean  "approved",                                                              null: false
    t.datetime "date_added",                                                            null: false
  end

  create_table "api_affiliate_transaction", primary_key: "affiliate_transaction_id", force: true do |t|
    t.integer  "affiliate_id",                          null: false
    t.integer  "order_id",                              null: false
    t.text     "description",                           null: false
    t.decimal  "amount",       precision: 15, scale: 4, null: false
    t.datetime "date_added",                            null: false
  end

  create_table "api_banner", primary_key: "banner_id", force: true do |t|
    t.string  "name",   limit: 64, null: false
    t.boolean "status",            null: false
  end

  create_table "api_banner_image", primary_key: "banner_image_id", force: true do |t|
    t.integer "banner_id", null: false
    t.string  "link",      null: false
    t.string  "image",     null: false
  end

  create_table "api_banner_image_description", id: false, force: true do |t|
    t.integer "banner_image_id",            null: false
    t.integer "language_id",                null: false
    t.integer "banner_id",                  null: false
    t.string  "title",           limit: 64, null: false
  end

  create_table "api_country", primary_key: "country_id", force: true do |t|
    t.string  "name",              limit: 128,                null: false
    t.string  "iso_code_2",        limit: 2,                  null: false
    t.string  "iso_code_3",        limit: 3,                  null: false
    t.text    "address_format",                               null: false
    t.boolean "postcode_required",                            null: false
    t.boolean "status",                        default: true, null: false
  end

  create_table "api_currency", primary_key: "currency_id", force: true do |t|
    t.string   "title",         limit: 32, null: false
    t.string   "code",          limit: 3,  null: false
    t.string   "symbol_left",   limit: 12, null: false
    t.string   "symbol_right",  limit: 12, null: false
    t.string   "decimal_place", limit: 1,  null: false
    t.float    "value",         limit: 24, null: false
    t.boolean  "status",                   null: false
    t.datetime "date_modified",            null: false
  end

  create_table "api_customer", primary_key: "customer_id", force: true do |t|
    t.integer  "store_id",                          default: 0,     null: false
    t.string   "firstname",              limit: 32,                 null: false
    t.string   "lastname",               limit: 32,                 null: false
    t.string   "email",                  limit: 96,                 null: false
    t.string   "telephone",              limit: 32,                 null: false
    t.string   "fax",                    limit: 32,                 null: false
    t.string   "encrypted_password",     limit: 70, default: "",    null: false
    t.string   "salt",                   limit: 9,                  null: false
    t.string   "api_key",                limit: 32
    t.boolean  "newsletter",                        default: false, null: false
    t.integer  "address_id",                        default: 0,     null: false
    t.integer  "customer_group_id",                                 null: false
    t.string   "ip",                     limit: 40, default: "0",   null: false
    t.boolean  "status",                                            null: false
    t.boolean  "approved",                                          null: false
    t.string   "token",                                             null: false
    t.datetime "date_added",                                        null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_customer", ["api_key"], name: "api_key", unique: true, using: :btree
  add_index "api_customer", ["email"], name: "index_api_customer_on_email", unique: true, using: :btree
  add_index "api_customer", ["reset_password_token"], name: "index_api_customer_on_reset_password_token", unique: true, using: :btree

  create_table "api_customer_ban_ip", primary_key: "customer_ban_ip_id", force: true do |t|
    t.string "ip", limit: 40, null: false
  end

  add_index "api_customer_ban_ip", ["ip"], name: "ip", using: :btree

  create_table "api_customer_group", primary_key: "customer_group_id", force: true do |t|
    t.integer "approval",            null: false
    t.integer "company_id_display",  null: false
    t.integer "company_id_required", null: false
    t.integer "tax_id_display",      null: false
    t.integer "tax_id_required",     null: false
    t.integer "sort_order",          null: false
  end

  create_table "api_customer_group_description", id: false, force: true do |t|
    t.integer "customer_group_id",            null: false
    t.integer "language_id",                  null: false
    t.string  "name",              limit: 32, null: false
    t.text    "description",                  null: false
  end

  add_index "api_customer_group_description", ["customer_group_id"], name: "customer_group_id", using: :btree

  create_table "api_customer_history", primary_key: "customer_history_id", force: true do |t|
    t.integer  "customer_id", null: false
    t.text     "comment",     null: false
    t.datetime "date_added",  null: false
  end

  create_table "api_customer_ip", primary_key: "customer_ip_id", force: true do |t|
    t.integer  "customer_id",            null: false
    t.string   "ip",          limit: 40, null: false
    t.datetime "date_added",             null: false
  end

  add_index "api_customer_ip", ["ip"], name: "ip", using: :btree

  create_table "api_customer_online", primary_key: "ip", force: true do |t|
    t.integer  "customer_id", null: false
    t.text     "url",         null: false
    t.text     "referer",     null: false
    t.datetime "date_added",  null: false
  end

  create_table "api_extension", primary_key: "extension_id", force: true do |t|
    t.string "type", limit: 32, null: false
    t.string "code", limit: 32, null: false
  end

  create_table "api_geo_zone", primary_key: "geo_zone_id", force: true do |t|
    t.string   "name",          limit: 32, null: false
    t.string   "description",              null: false
    t.datetime "date_modified",            null: false
    t.datetime "date_added",               null: false
  end

  create_table "api_information", primary_key: "information_id", force: true do |t|
    t.integer "parent_id",  default: 0,     null: false
    t.integer "bottom",     default: 0,     null: false
    t.boolean "top",        default: false, null: false
    t.integer "sort_order", default: 0,     null: false
    t.boolean "status",     default: true,  null: false
  end

  create_table "api_information_description", id: false, force: true do |t|
    t.integer "information_id",            null: false
    t.integer "language_id",               null: false
    t.string  "title",          limit: 64, null: false
    t.text    "description",               null: false
  end

  create_table "api_information_to_layout", id: false, force: true do |t|
    t.integer "information_id", null: false
    t.integer "store_id",       null: false
    t.integer "layout_id",      null: false
  end

  create_table "api_information_to_store", id: false, force: true do |t|
    t.integer "information_id", null: false
    t.integer "store_id",       null: false
  end

  create_table "api_language", primary_key: "language_id", force: true do |t|
    t.string  "name",       limit: 32,             null: false
    t.string  "code",       limit: 5,              null: false
    t.string  "locale",                            null: false
    t.string  "image",      limit: 64,             null: false
    t.string  "directory",  limit: 32,             null: false
    t.string  "filename",   limit: 64,             null: false
    t.integer "sort_order",            default: 0, null: false
    t.boolean "status",                            null: false
  end

  add_index "api_language", ["name"], name: "name", using: :btree

  create_table "api_layout", primary_key: "layout_id", force: true do |t|
    t.string "name", limit: 64, null: false
  end

  create_table "api_layout_route", primary_key: "layout_route_id", force: true do |t|
    t.integer "layout_id", null: false
    t.integer "store_id",  null: false
    t.string  "route",     null: false
  end

  create_table "api_setting", primary_key: "setting_id", force: true do |t|
    t.integer "store_id",              default: 0, null: false
    t.string  "group",      limit: 32,             null: false
    t.string  "key",        limit: 64,             null: false
    t.text    "value",                             null: false
    t.boolean "serialized",                        null: false
  end

  create_table "api_store", primary_key: "store_id", force: true do |t|
    t.string "name", limit: 64, null: false
    t.string "url",             null: false
    t.string "ssl",             null: false
  end

  create_table "api_url_alias", primary_key: "url_alias_id", force: true do |t|
    t.string "query",   null: false
    t.string "keyword", null: false
  end

  create_table "api_user", primary_key: "user_id", force: true do |t|
    t.integer  "user_group_id",            null: false
    t.string   "username",      limit: 20, null: false
    t.string   "password",      limit: 40, null: false
    t.string   "salt",          limit: 9,  null: false
    t.string   "firstname",     limit: 32, null: false
    t.string   "lastname",      limit: 32, null: false
    t.string   "email",         limit: 96, null: false
    t.string   "code",          limit: 40, null: false
    t.string   "ip",            limit: 40, null: false
    t.boolean  "status",                   null: false
    t.datetime "date_added",               null: false
  end

  create_table "api_user_group", primary_key: "user_group_id", force: true do |t|
    t.string "name",       limit: 64, null: false
    t.text   "permission",            null: false
  end

  create_table "api_zone", primary_key: "zone_id", force: true do |t|
    t.integer "country_id",                            null: false
    t.string  "name",       limit: 128,                null: false
    t.string  "code",       limit: 32,                 null: false
    t.boolean "status",                 default: true, null: false
  end

  create_table "api_zone_to_geo_zone", primary_key: "zone_to_geo_zone_id", force: true do |t|
    t.integer  "country_id",                null: false
    t.integer  "zone_id",       default: 0, null: false
    t.integer  "geo_zone_id",               null: false
    t.datetime "date_added",                null: false
    t.datetime "date_modified",             null: false
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

end
