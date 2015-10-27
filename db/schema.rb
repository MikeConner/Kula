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

ActiveRecord::Schema.define(version: 20151027175214) do

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
    t.integer  "month",                              null: false
    t.integer  "year",                               null: false
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
    t.integer  "partner_id",                                                           null: false
    t.integer  "cause_id",                                                             null: false
    t.integer  "year",                                                                 null: false
    t.string   "balance_type",        limit: 16
    t.decimal  "jan",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "feb",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "mar",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "apr",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "may",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "jun",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "jul",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "aug",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "sep",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "oct",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "nov",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "dec",                            precision: 8, scale: 2, default: 0.0, null: false
    t.decimal  "total",                          precision: 8, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "prior_year_rollover",            precision: 8, scale: 2, default: 0.0, null: false
  end

  add_index "cause_balances", ["cause_id", "balance_type"], name: "index_cause_balances_on_cause_id_and_balance_type", using: :btree
  add_index "cause_balances", ["cause_id"], name: "index_cause_balances_on_cause_id", using: :btree
  add_index "cause_balances", ["partner_id", "cause_id", "year", "balance_type"], name: "cause_balances_primary_key", unique: true, using: :btree

  create_table "cause_transactions", force: :cascade do |t|
    t.integer  "partner_identifier",                                         null: false
    t.integer  "cause_identifier",                                           null: false
    t.integer  "month",                                                      null: false
    t.integer  "year",                                                       null: false
    t.decimal  "gross_amount",         precision: 8, scale: 2, default: 0.0
    t.decimal  "net_amount",           precision: 8, scale: 2, default: 0.0
    t.decimal  "donee_amount",         precision: 8, scale: 2, default: 0.0
    t.decimal  "discounts_amount",     precision: 8, scale: 2, default: 0.0
    t.decimal  "fees_amount",          precision: 8, scale: 2, default: 0.0
    t.decimal  "calc_kula_fee",        precision: 8, scale: 2, default: 0.0
    t.decimal  "calc_foundation_fee",  precision: 8, scale: 2, default: 0.0
    t.decimal  "calc_distributor_fee", precision: 8, scale: 2, default: 0.0
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.decimal  "calc_credit_card_fee", precision: 8, scale: 2, default: 0.0
  end

  add_index "cause_transactions", ["cause_identifier"], name: "index_cause_transactions_on_cause_identifier", using: :btree
  add_index "cause_transactions", ["month", "year"], name: "index_cause_transactions_on_month_and_year", using: :btree
  add_index "cause_transactions", ["partner_identifier"], name: "index_cause_transactions_on_partner_identifier", using: :btree
  add_index "cause_transactions", ["year"], name: "index_cause_transactions_on_year", using: :btree

  create_table "causes", primary_key: "cause_id", force: :cascade do |t|
    t.integer  "source_id",                                            null: false
    t.string   "source_cause_id",              limit: 64
    t.integer  "mcr_school_id"
    t.datetime "enhanced_date"
    t.string   "unenhanced_cause_id",          limit: 64
    t.string   "tax_id",                       limit: 64
    t.integer  "cause_type",                               default: 1, null: false
    t.integer  "has_ach_info",                             default: 0, null: false
    t.integer  "k8",                                       default: 0, null: false
    t.string   "org_name",                     limit: 255,             null: false
    t.string   "old_org_name",                 limit: 255
    t.string   "org_contact_first_name",       limit: 64
    t.string   "old_org_contact_first_name",   limit: 64
    t.string   "org_contact_last_name",        limit: 64
    t.string   "old_org_contact_last_name",    limit: 64
    t.string   "org_contact_email",            limit: 255
    t.string   "old_org_contact_email",        limit: 255
    t.string   "mcr_role",                     limit: 50
    t.string   "mcr_user_level",               limit: 25
    t.string   "org_email",                    limit: 255
    t.string   "org_phone",                    limit: 64
    t.string   "old_org_phone",                limit: 64
    t.string   "org_fax",                      limit: 64
    t.text     "mission"
    t.text     "additional_description"
    t.text     "description"
    t.string   "address1",                     limit: 128
    t.string   "old_address1",                 limit: 128
    t.string   "address2",                     limit: 128
    t.string   "address3",                     limit: 128
    t.float    "latitude"
    t.float    "longitude"
    t.string   "city",                         limit: 64
    t.string   "old_city",                     limit: 64
    t.string   "region",                       limit: 64
    t.string   "old_region",                   limit: 64
    t.string   "country",                      limit: 2,               null: false
    t.string   "postal_code",                  limit: 16
    t.string   "old_postal_code",              limit: 16
    t.string   "mailing_address",              limit: 128
    t.string   "mailing_city",                 limit: 64
    t.string   "mailing_state",                limit: 64
    t.string   "mailing_postal_code",          limit: 16
    t.string   "site_url",                     limit: 255
    t.string   "old_site_url",                 limit: 255
    t.string   "logo_url",                     limit: 255
    t.string   "logo_small_url",               limit: 255
    t.string   "image_url",                    limit: 255
    t.string   "video_url",                    limit: 255
    t.string   "facebook_url",                 limit: 255
    t.string   "newsletter_url",               limit: 255
    t.string   "photos_url",                   limit: 255
    t.string   "twitter_username",             limit: 16
    t.string   "school_grades_desc",           limit: 255
    t.string   "school_student_range_cd_desc", limit: 255
    t.integer  "ethnic_african_american_pct"
    t.integer  "ethnic_asian_american_pct"
    t.integer  "ethnic_hispanic_american_pct"
    t.integer  "ethnic_native_american_pct"
    t.integer  "ethnic_caucasian_pct"
    t.text     "keywords"
    t.text     "countries_operation"
    t.string   "language",                     limit: 8,               null: false
    t.string   "donation_5",                   limit: 128
    t.string   "donation_10",                  limit: 128
    t.string   "donation_25",                  limit: 128
    t.string   "donation_50",                  limit: 128
    t.string   "donation_100",                 limit: 128
    t.integer  "is_prison_school",                         default: 0
    t.integer  "views",                                    default: 0, null: false
    t.integer  "donations",                                default: 0, null: false
    t.integer  "comment_count",                            default: 0, null: false
    t.integer  "favorite_count",                           default: 0, null: false
    t.integer  "share_count",                              default: 0, null: false
    t.integer  "mcr_net_points"
    t.integer  "status"
    t.integer  "donatable_status",                         default: 1
    t.integer  "mcr_status"
    t.string   "payment_first_name",           limit: 64
    t.string   "payment_last_name",            limit: 64
    t.string   "payment_email",                limit: 255
    t.string   "payment_currency",             limit: 3
    t.string   "payment_address1",             limit: 128
    t.string   "old_payment_address1",         limit: 128
    t.string   "payment_address2",             limit: 128
    t.string   "old_payment_address2",         limit: 128
    t.string   "bank_routing_number",          limit: 16
    t.string   "bank_account_number",          limit: 32
    t.string   "iban",                         limit: 34
    t.string   "paypal_email",                 limit: 255
    t.integer  "cached",                                   default: 0
    t.datetime "updated"
    t.datetime "old_updated"
    t.datetime "created",                                              null: false
    t.point    "latitude_longitude_point"
    t.integer  "cause_identifier",                                     null: false
  end

  add_index "causes", ["cause_id"], name: "index_causes_on_cause_id", unique: true, using: :btree
  add_index "causes", ["cause_identifier"], name: "index_causes_on_cause_identifier", unique: true, using: :btree
  add_index "causes", ["org_name"], name: "index_causes_on_org_name", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "delayed_rakes", force: :cascade do |t|
    t.integer  "job_identifier"
    t.string   "name",           limit: 32
    t.text     "params"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "distributors", id: false, force: :cascade do |t|
    t.integer  "distributor_identifier",            null: false
    t.string   "name",                   limit: 64, null: false
    t.string   "display_name",           limit: 64
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "distributors", ["distributor_identifier"], name: "index_distributors_on_distributor_identifier", unique: true, using: :btree

  create_table "global_settings", force: :cascade do |t|
    t.date     "current_period", null: false
    t.text     "other"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "kula_fees", force: :cascade do |t|
    t.integer  "partner_identifier"
    t.date     "effective_date"
    t.date     "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "us_school_rate",         precision: 6, scale: 4, default: 0.0
    t.decimal  "us_charity_rate",        precision: 6, scale: 4, default: 0.0
    t.decimal  "intl_charity_rate",      precision: 6, scale: 4, default: 0.0
    t.decimal  "us_school_kf_rate",      precision: 6, scale: 4, default: 0.0
    t.decimal  "us_charity_kf_rate",     precision: 6, scale: 4, default: 0.0
    t.decimal  "intl_charity_kf_rate",   precision: 6, scale: 4, default: 0.0
    t.decimal  "distributor_rate",       precision: 6, scale: 4, default: 0.0
    t.integer  "distributor_identifier"
    t.decimal  "mcr_cc_rate",            precision: 6, scale: 4, default: 0.0
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
    t.string   "status",         limit: 16,                          default: "Outstanding", null: false
    t.decimal  "amount",                     precision: 8, scale: 2,                         null: false
    t.datetime "date"
    t.string   "confirmation",   limit: 255
    t.string   "payment_method", limit: 8,                           default: "Check",       null: false
    t.string   "address",        limit: 255
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cause_id",                                                                   null: false
    t.integer  "check_num",                                                                  null: false
    t.integer  "month",                                                                      null: false
    t.integer  "year",                                                                       null: false
  end

  add_index "payments", ["batch_id"], name: "index_payments_on_batch_id", using: :btree

  create_table "replicated_balance_transactions", primary_key: "transaction_id", force: :cascade do |t|
    t.integer  "type",                                             null: false
    t.integer  "user_id",                                          null: false
    t.string   "cause_id",     limit: 64
    t.integer  "campaign_id"
    t.integer  "category_id"
    t.integer  "partner_id"
    t.string   "currency",     limit: 3,                           null: false
    t.decimal  "amount",                  precision: 11, scale: 2, null: false
    t.integer  "status",                                           null: false
    t.string   "session_uuid", limit: 36
    t.datetime "updated"
    t.datetime "created",                                          null: false
  end

  create_table "replicated_balances", id: false, force: :cascade do |t|
    t.integer  "user_id",                                       null: false
    t.integer  "partner_id",                                    null: false
    t.string   "currency",   limit: 3,                          null: false
    t.decimal  "amount",               precision: 11, scale: 2, null: false
    t.datetime "updated"
    t.datetime "created",                                       null: false
  end

  create_table "replicated_burn_links", primary_key: "burn_link_id", force: :cascade do |t|
    t.integer  "burn_balance_transaction_id",                                     null: false
    t.integer  "earn_balance_transaction_id"
    t.integer  "type",                                                            null: false
    t.string   "cut_payee_id",                limit: 32
    t.decimal  "amount",                                 precision: 11, scale: 2, null: false
    t.decimal  "cut_percent",                            precision: 6,  scale: 3
    t.decimal  "cut_amount",                             precision: 11, scale: 2
    t.datetime "matched",                                                         null: false
    t.datetime "updated"
  end

  create_table "replicated_partner_codes", primary_key: "code", force: :cascade do |t|
    t.integer  "balance_transaction_id"
    t.integer  "partner_id",                                                            null: false
    t.decimal  "value",                            precision: 11, scale: 2,             null: false
    t.string   "currency",               limit: 3,                                      null: false
    t.integer  "user_id"
    t.datetime "created",                                                               null: false
    t.datetime "claimed"
    t.integer  "batch_id"
    t.decimal  "cut_percent",                      precision: 6,  scale: 3
    t.integer  "active",                                                    default: 1
    t.datetime "activated"
    t.integer  "batch_partner_id"
  end

  create_table "replicated_partner_transaction", primary_key: "partner_transaction_id", force: :cascade do |t|
    t.integer  "balance_transaction_id"
    t.integer  "partner_id"
    t.integer  "user_id"
    t.string   "status",                   limit: 64
    t.datetime "created"
    t.datetime "last_modified"
    t.string   "points",                   limit: 50
    t.string   "user__id",                 limit: 50
    t.string   "amount",                   limit: 50
    t.string   "currency",                 limit: 50
    t.string   "ip_address",               limit: 50
    t.string   "order_description",        limit: 50
    t.string   "result_avs_result",        limit: 50
    t.string   "result_billing_id",        limit: 50
    t.string   "result_code",              limit: 50
    t.string   "result_customer_vault_id", limit: 50
    t.string   "result_cvv_result",        limit: 50
    t.string   "result_result_code",       limit: 50
    t.string   "result_shipping_id",       limit: 50
    t.string   "result_text",              limit: 50
    t.string   "result_transaction_id",    limit: 50
    t.string   "action_type",              limit: 50
    t.string   "authorization__code",      limit: 50
    t.string   "avs__result",              limit: 50
    t.string   "billing_first_name",       limit: 50
    t.string   "billing_last_name",        limit: 50
    t.string   "billing_postal",           limit: 50
    t.string   "customer__id",             limit: 50
    t.string   "customer__vault_id",       limit: 50
    t.string   "ccv__result",              limit: 50
    t.string   "industry",                 limit: 50
    t.string   "ip__address",              limit: 50
    t.string   "order__description",       limit: 50
    t.string   "processor_id",             limit: 50
    t.string   "processor_result_code",    limit: 50
    t.string   "processor_result_text",    limit: 50
    t.string   "result",                   limit: 50
    t.string   "result__text",             limit: 50
    t.string   "result__code",             limit: 50
    t.string   "shipping__amount",         limit: 50
    t.string   "tax_amount",               limit: 50
    t.string   "token__id",                limit: 50
    t.string   "transaction__id",          limit: 50
    t.string   "surcharge_amount",         limit: 50
    t.string   "tip_amount",               limit: 50
    t.string   "amount_authorized",        limit: 50
    t.string   "giving_code",              limit: 50
    t.string   "giving_code_email",        limit: 50
    t.string   "giving_code_name",         limit: 50
    t.string   "rr_transaction_id",        limit: 50
    t.string   "cash_value",               limit: 50
    t.string   "client_transaction_id",    limit: 50
    t.string   "transaction_id",           limit: 50
    t.string   "final_balance",            limit: 50
    t.string   "billing_billing__id",      limit: 50
    t.string   "shipping_shipping__id",    limit: 50
  end

  create_table "replicated_partner_transaction_field", id: false, force: :cascade do |t|
    t.integer "partner_transaction_id",                         null: false
    t.string  "name",                   limit: 30,              null: false
    t.string  "value",                  limit: 50, default: "", null: false
  end

  create_table "replicated_partner_user_map", id: false, force: :cascade do |t|
    t.integer "user_id",                         null: false
    t.integer "partner_id",                      null: false
    t.string  "partner_identity_id", limit: 255
  end

  create_table "replicated_users", primary_key: "user_id", force: :cascade do |t|
    t.string   "email",           limit: 255, null: false
    t.integer  "facebook_id",     limit: 8
    t.string   "password",        limit: 64
    t.date     "birthday"
    t.string   "gender",          limit: 1
    t.string   "first_name",      limit: 64
    t.string   "last_name",       limit: 64
    t.string   "name_prefix",     limit: 4
    t.string   "donor_type",      limit: 1
    t.string   "group_name",      limit: 255
    t.datetime "last_login"
    t.datetime "last_activity"
    t.datetime "account_created",             null: false
    t.string   "address1",        limit: 128
    t.string   "address2",        limit: 128
    t.string   "city",            limit: 64
    t.string   "region",          limit: 64
    t.string   "country",         limit: 2,   null: false
    t.string   "postal_code",     limit: 16
    t.integer  "newsletter"
    t.integer  "program_email"
    t.integer  "tax_receipts"
  end

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
    t.integer  "partner_12_balance",     limit: 8
    t.integer  "partner_14_balance",     limit: 8
    t.integer  "partner_22_balance",     limit: 8
    t.integer  "partner_24_balance",     limit: 8
    t.integer  "partner_10_balance",     limit: 8
    t.integer  "partner_11_balance",     limit: 8
  end

  add_index "users", ["cause_id"], name: "index_users_on_cause_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["partner_id"], name: "index_users_on_partner_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
