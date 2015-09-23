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

ActiveRecord::Schema.define(version: 20150919215930) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "adjustments", force: :cascade do |t|
    t.integer  "batch_id"
    t.decimal  "amount",     precision: 8, scale: 2, null: false
    t.datetime "date"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cause_id"
  end

  add_index "adjustments", ["batch_id"], name: "index_adjustments_on_batch_id", using: :btree

  create_table "batches", force: :cascade do |t|
    t.integer  "partner_id"
    t.integer  "user_id"
    t.string   "name",        limit: 64
    t.datetime "date"
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cause_balances", force: :cascade do |t|
    t.integer  "partner_id",                                                    null: false
    t.integer  "cause_id",                                                      null: false
    t.integer  "year",                                                          null: false
    t.string   "balance_type", limit: 16
    t.decimal  "jan",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "feb",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "mar",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "apr",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "may",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "jun",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "jul",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "aug",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "sep",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "oct",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "nov",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "dec",                     precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "total",                   precision: 8, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cause_balances", ["cause_id"], name: "index_cause_balances_on_cause_id", using: :btree
  add_index "cause_balances", ["partner_id", "cause_id", "year", "balance_type"], name: "cause_balances_primary_key", unique: true, using: :btree

  create_table "cause_transactions", id: false, force: :cascade do |t|
    t.integer  "transaction_identifier",                         null: false
    t.integer  "partner_identifier"
    t.integer  "month",                                          null: false
    t.integer  "year",                                           null: false
    t.decimal  "gross_amount",           precision: 8, scale: 2
    t.decimal  "net_amount",             precision: 8, scale: 2
    t.decimal  "donee_amount",           precision: 8, scale: 2
    t.decimal  "discounts_amount",       precision: 6, scale: 2
    t.decimal  "fees_amount",            precision: 6, scale: 2
    t.decimal  "calc_kula_fee",          precision: 6, scale: 2
    t.decimal  "calc_foundation_fee",    precision: 6, scale: 2
    t.decimal  "calc_distributor_fee",   precision: 6, scale: 2
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "cause_transactions", ["month", "year"], name: "index_cause_transactions_on_month_and_year", using: :btree
  add_index "cause_transactions", ["partner_identifier"], name: "index_cause_transactions_on_partner_identifier", using: :btree
  add_index "cause_transactions", ["transaction_identifier"], name: "index_cause_transactions_on_transaction_identifier", unique: true, using: :btree

  create_table "causes", id: false, force: :cascade do |t|
    t.string   "name",                limit: 255,                                null: false
    t.integer  "cause_type",                                                     null: false
    t.boolean  "has_ach_info",                                   default: false, null: false
    t.string   "email",               limit: 255
    t.string   "phone",               limit: 64
    t.string   "fax",                 limit: 64
    t.string   "tax_id",              limit: 64
    t.string   "address_1",           limit: 128
    t.string   "address_2",           limit: 128
    t.string   "address_3",           limit: 128
    t.string   "city",                limit: 64
    t.string   "region",              limit: 64
    t.string   "country",             limit: 2,                                  null: false
    t.string   "postal_code",         limit: 16
    t.string   "mailing_address",     limit: 128
    t.string   "mailing_city",        limit: 64
    t.string   "mailing_state",       limit: 64
    t.string   "mailing_postal_code", limit: 16
    t.string   "site_url",            limit: 255
    t.string   "logo_url",            limit: 255
    t.decimal  "latitude",                        precision: 10
    t.decimal  "longitude",                       precision: 10
    t.text     "mission"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cause_identifier",                                               null: false
  end

  create_table "distributors", id: false, force: :cascade do |t|
    t.integer  "distributor_identifier",            null: false
    t.string   "name",                   limit: 64, null: false
    t.string   "display_name",           limit: 64
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "distributors", ["distributor_identifier"], name: "index_distributors_on_distributor_identifier", unique: true, using: :btree

  create_table "kula_fees", force: :cascade do |t|
    t.integer  "partner_identifier"
    t.date     "effective_date"
    t.date     "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "us_school_rate",         precision: 6, scale: 4
    t.decimal  "us_charity_rate",        precision: 6, scale: 4
    t.decimal  "intl_charity_rate",      precision: 6, scale: 4
    t.decimal  "us_school_kf_rate",      precision: 6, scale: 4
    t.decimal  "us_charity_kf_rate",     precision: 6, scale: 4
    t.decimal  "intl_charity_kf_rate",   precision: 6, scale: 4
    t.decimal  "distributor_rate",       precision: 6, scale: 4
    t.integer  "distributor_identifier"
  end

  create_table "partners", primary_key: "partner_identifier", force: :cascade do |t|
    t.string   "name",         limit: 64,                 null: false
    t.string   "display_name", limit: 64,                 null: false
    t.string   "domain",       limit: 64,                 null: false
    t.string   "currency",     limit: 3,  default: "USD", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payments", force: :cascade do |t|
    t.integer  "batch_id"
    t.string   "status",         limit: 16
    t.decimal  "amount",                     precision: 8, scale: 2, null: false
    t.datetime "date"
    t.string   "confirmation",   limit: 255
    t.string   "payment_method", limit: 8
    t.string   "address",        limit: 255
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cause_id"
  end

  add_index "payments", ["batch_id"], name: "index_payments_on_batch_id", using: :btree

  create_table "stripe_accounts", force: :cascade do |t|
    t.integer  "cause_id"
    t.string   "token",      limit: 32, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "stripe_accounts", ["token"], name: "index_stripe_accounts_on_token", unique: true, using: :btree

  create_table "transactions_by_cause", id: false, force: :cascade do |t|
    t.integer "partner_id"
    t.integer "month"
    t.integer "year"
    t.float   "Gross_Contribution_Amount"
    t.float   "Discounts_Amount"
    t.float   "Net_amount"
    t.float   "Kula_And_Foundation_fees"
    t.float   "Donee_amount"
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

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
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
