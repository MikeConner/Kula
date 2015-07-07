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

ActiveRecord::Schema.define(version: 20150707050002) do

  create_table "adjustments", force: true do |t|
    t.integer  "batch_id"
    t.decimal  "amount",     precision: 8, scale: 2, null: false
    t.datetime "date"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "batches", force: true do |t|
    t.integer  "partner_id"
    t.integer  "user_id"
    t.string   "name",        limit: 32
    t.datetime "date"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cause_balances", force: true do |t|
    t.integer  "partner_id"
    t.integer  "cause_id"
    t.integer  "year",                                                        null: false
    t.string   "cause_type", limit: 16
    t.decimal  "jan",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "feb",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "mar",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "apr",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "may",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "jun",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "jul",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "aug",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "sep",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "oct",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "nov",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "dec",                   precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "total",                 precision: 8, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cause_balances", ["partner_id", "cause_id", "year", "cause_type"], name: "cause_balances_primary_key", unique: true, using: :btree

  create_table "causes", id: false, force: true do |t|
    t.string   "cause_identifier",    limit: 64,                                           null: false
    t.string   "name",                                                                     null: false
    t.integer  "cause_type",                                                               null: false
    t.boolean  "has_ach_info",                                             default: false, null: false
    t.string   "email"
    t.string   "phone",               limit: 64
    t.string   "fax",                 limit: 64
    t.string   "tax_id",              limit: 64
    t.string   "address_1",           limit: 128
    t.string   "address_2",           limit: 128
    t.string   "address_3",           limit: 128
    t.string   "city",                limit: 64
    t.string   "region",              limit: 64
    t.string   "country",             limit: 2,                                            null: false
    t.string   "postal_code",         limit: 16
    t.string   "mailing_address",     limit: 128
    t.string   "mailing_city",        limit: 64
    t.string   "mailing_state",       limit: 64
    t.string   "mailing_postal_code", limit: 16
    t.string   "site_url"
    t.string   "logo_url"
    t.decimal  "latitude",                        precision: 10, scale: 0
    t.decimal  "longitude",                       precision: 10, scale: 0
    t.text     "mission"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "causes", ["cause_identifier"], name: "index_causes_on_cause_identifier", unique: true, using: :btree

  create_table "kula_fees", force: true do |t|
    t.integer  "partner_id"
    t.decimal  "rate",            precision: 6, scale: 3, null: false
    t.date     "effective_date"
    t.date     "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partners", primary_key: "partner_identifier", force: true do |t|
    t.string   "name",         limit: 64,                 null: false
    t.string   "display_name", limit: 64,                 null: false
    t.string   "domain",       limit: 64,                 null: false
    t.string   "currency",     limit: 3,  default: "USD", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: true do |t|
    t.integer  "batch_id"
    t.string   "status",         limit: 16
    t.decimal  "amount",                    precision: 8, scale: 2, null: false
    t.datetime "date"
    t.string   "confirmation"
    t.string   "payment_method", limit: 8
    t.string   "address"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stripe_accounts", force: true do |t|
    t.integer  "cause_id"
    t.string   "token",      limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stripe_accounts", ["token"], name: "index_stripe_accounts_on_token", unique: true, using: :btree

  create_table "transactions_by_cause", id: false, force: true do |t|
    t.integer "partner_id"
    t.integer "month"
    t.integer "year"
    t.float   "Gross_Contribution_Amount",       limit: 53
    t.float   "Discounts_Amount",                limit: 53
    t.float   "Net_amount",                      limit: 53
    t.float   "Kula_And_Foundation_fees",        limit: 53
    t.float   "Donee_amount",                    limit: 53
    t.text    "Organization_name"
    t.text    "Organization_name_for_address"
    t.text    "Address1_2_3"
    t.text    "City_State_Zip"
    t.text    "Country"
    t.text    "Type"
    t.text    "Organization_Contact_First_Name"
    t.text    "Organization_Contact_Last_Name"
    t.text    "Organization_Contact_Email"
    t.text    "Organization_Email"
    t.text    "Tax_ID"
    t.integer "Has_ACH_Information"
    t.integer "Cause_ID"
  end

  create_table "users", force: true do |t|
    t.string   "email",                             default: "", null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                   limit: 16
    t.integer  "partner_id"
    t.integer  "cause_id"
  end

  add_index "users", ["cause_id"], name: "index_users_on_cause_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["partner_id"], name: "index_users_on_partner_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
