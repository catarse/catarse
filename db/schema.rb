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

ActiveRecord::Schema.define(version: 20160804170635) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"
  enable_extension "unaccent"
  enable_extension "pgcrypto"

  create_enum "project_state_order", "archived", "created", "sent", "publishable", "published", "finished"
  create_table "oauth_providers", force: true do |t|
    t.text     "name",       null: false
    t.text     "key",        null: false
    t.text     "secret",     null: false
    t.text     "scope"
    t.integer  "order"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "strategy"
    t.text     "path"
    t.index ["name"], :name => "oauth_providers_name_unique", :unique => true
  end

  create_table "countries", force: true do |t|
    t.text     "name",       null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.text     "email",                                                   null: false
    t.text     "name"
    t.boolean  "newsletter",                              default: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.boolean  "admin",                                   default: false
    t.text     "address_street"
    t.text     "address_number"
    t.text     "address_complement"
    t.text     "address_neighbourhood"
    t.text     "address_city"
    t.text     "address_state"
    t.text     "address_zip_code"
    t.text     "phone_number"
    t.text     "locale",                                  default: "pt",  null: false
    t.text     "cpf"
    t.string   "encrypted_password",          limit: 128, default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                           default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "twitter"
    t.string   "facebook_link"
    t.string   "other_link"
    t.text     "uploaded_image"
    t.string   "moip_login"
    t.string   "state_inscription"
    t.integer  "channel_id"
    t.datetime "deactivated_at"
    t.text     "reactivate_token"
    t.text     "address_country"
    t.integer  "country_id"
    t.text     "authentication_token", :default => { :expr => "md5(((random())::text || (clock_timestamp())::text))" },                                    null: false
    t.boolean  "zero_credits",                            default: false
    t.text     "about_html"
    t.text     "cover_image"
    t.text     "permalink"
    t.boolean  "subscribed_to_project_posts",             default: true
    t.tsvector "full_text_index",                                         null: false
    t.boolean  "subscribed_to_new_followers",             default: true
    t.index ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
    t.index ["channel_id"], :name => "fk__users_channel_id"
    t.index ["country_id"], :name => "fk__users_country_id"
    t.index ["email"], :name => "index_users_on_email", :unique => true
    t.index ["full_text_index"], :name => "users_full_text_index_ix", :kind => "gin"
    t.index ["id"], :name => "user_admin_id_ix", :conditions => "admin"
    t.index ["id"], :name => "users_id_idx", :unique => true, :order => {"id" => :desc}
    t.index ["name"], :name => "index_users_on_name"
    t.index ["permalink"], :name => "index_users_on_permalink", :unique => true
    t.index ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
    t.foreign_key ["country_id"], "countries", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_users_country_id"
  end

  create_table "authorizations", force: true do |t|
    t.integer  "oauth_provider_id", null: false
    t.integer  "user_id",           null: false
    t.text     "uid",               null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "last_token"
    t.index ["oauth_provider_id", "user_id"], :name => "index_authorizations_on_oauth_provider_id_and_user_id", :unique => true
    t.index ["oauth_provider_id"], :name => "fk__authorizations_oauth_provider_id"
    t.index ["uid", "oauth_provider_id"], :name => "index_authorizations_on_uid_and_oauth_provider_id", :unique => true
    t.index ["user_id"], :name => "fk__authorizations_user_id"
    t.foreign_key ["oauth_provider_id"], "oauth_providers", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_authorizations_oauth_provider_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_authorizations_user_id"
  end

  create_table "categories", force: true do |t|
    t.text     "name_pt",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.string   "name_en"
    t.string   "name_fr"
    t.index ["name_pt"], :name => "categories_name_unique", :unique => true
    t.index ["name_pt"], :name => "index_categories_on_name_pt"
  end

  create_table "states", force: true do |t|
    t.string   "name",       null: false
    t.string   "acronym",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["acronym"], :name => "states_acronym_unique", :unique => true
    t.index ["name"], :name => "states_name_unique", :unique => true
  end

  create_table "cities", force: true do |t|
    t.text    "name",     null: false
    t.integer "state_id", null: false
    t.index ["state_id"], :name => "fk__cities_state_id"
    t.foreign_key ["state_id"], "states", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_cities_state_id"
  end

  create_table "origins", force: true do |t|
    t.text     "domain",     null: false
    t.text     "referral"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["domain", "referral"], :name => "index_origins_on_domain_and_referral", :unique => true
  end

# Could not dump table "project_states" because of following StandardError
#   Unknown type 'project_state_order' for column 'state_order'

  create_table "projects", force: true do |t|
    t.text     "name",                                        null: false
    t.integer  "user_id",                                     null: false
    t.integer  "category_id",                                 null: false
    t.decimal  "goal"
    t.text     "headline"
    t.text     "video_url"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "about_html"
    t.boolean  "recommended",               default: false
    t.text     "permalink", :default => { :expr => "('project_'::text || (currval('projects_id_seq'::regclass))::text)" },                                   null: false
    t.text     "video_thumbnail"
    t.string   "state",                     default: "draft", null: false
    t.integer  "online_days"
    t.text     "more_links"
    t.string   "uploaded_image"
    t.string   "video_embed_url"
    t.text     "audited_user_name"
    t.text     "audited_user_cpf"
    t.text     "audited_user_moip_login"
    t.text     "audited_user_phone_number"
    t.text     "traffic_sources"
    t.text     "budget"
    t.tsvector "full_text_index"
    t.text     "budget_html"
    t.datetime "expires_at"
    t.integer  "city_id"
    t.integer  "origin_id"
    t.decimal  "service_fee",               default: 0.13
    t.integer  "total_installments",        default: 3,       null: false
    t.text     "mode",                      default: "aon",   null: false
    t.text     "tracker_snippet_html"
    t.index ["category_id"], :name => "index_projects_on_category_id"
    t.index ["city_id"], :name => "index_projects_on_city_id"
    t.index ["full_text_index"], :name => "projects_full_text_index_ix", :kind => "gin"
    t.index ["name"], :name => "index_projects_on_name"
    t.index ["name"], :name => "projects_name_idx", :kind => "gist", :operator_class => {"name" => "gist_trgm_ops"}
    t.index ["origin_id"], :name => "fk__projects_origin_id"
    t.index ["permalink"], :name => "index_projects_on_permalink", :unique => true, :case_sensitive => false
    t.index ["user_id"], :name => "index_projects_on_user_id"
    t.foreign_key ["category_id"], "categories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "projects_category_id_reference"
    t.foreign_key ["city_id"], "cities", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_projects_city_id"
    t.foreign_key ["origin_id"], "origins", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_projects_origin_id"
    t.foreign_key ["state"], "project_states", ["state"], :on_update => :no_action, :on_delete => :no_action, :name => "projects_state_fkey"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "projects_user_id_reference"
  end

  create_table "balance_transfers", force: true do |t|
    t.integer  "user_id",     null: false
    t.decimal  "amount",      null: false
    t.text     "transfer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.index ["project_id"], :name => "fk__balance_transfers_project_id"
    t.index ["project_id"], :name => "unq_project_id_idx", :unique => true
    t.index ["user_id"], :name => "fk__balance_transfers_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_balance_transfers_project_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_balance_transfers_user_id"
  end

# Could not dump table "balance_transfer_pings" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

  create_table "donations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount"
    t.integer  "user_id"
    t.index ["user_id"], :name => "index_donations_on_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_donations_user_id"
  end

  create_table "rewards", force: true do |t|
    t.integer  "project_id",            null: false
    t.decimal  "minimum_value",         null: false
    t.integer  "maximum_contributions"
    t.text     "description",           null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.integer  "row_order"
    t.text     "last_changes"
    t.datetime "deliver_at"
    t.index ["project_id"], :name => "index_rewards_on_project_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "rewards_project_id_reference"
  end

  create_table "contributions", force: true do |t|
    t.integer  "project_id",                            null: false
    t.integer  "user_id",                               null: false
    t.integer  "reward_id"
    t.decimal  "value",                                 null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.boolean  "anonymous",             default: false, null: false
    t.boolean  "notified_finish",       default: false
    t.text     "payer_name"
    t.text     "payer_email",                           null: false
    t.text     "payer_document"
    t.text     "address_street"
    t.text     "address_number"
    t.text     "address_complement"
    t.text     "address_neighbourhood"
    t.text     "address_zip_code"
    t.text     "address_city"
    t.text     "address_state"
    t.text     "address_phone_number"
    t.text     "payment_choice"
    t.decimal  "payment_service_fee"
    t.text     "referral_link"
    t.integer  "country_id"
    t.datetime "deleted_at"
    t.integer  "donation_id"
    t.integer  "origin_id"
    t.index ["country_id"], :name => "fk__contributions_country_id"
    t.index ["created_at"], :name => "index_contributions_on_created_at"
    t.index ["donation_id"], :name => "fk__contributions_donation_id"
    t.index ["origin_id"], :name => "fk__contributions_origin_id"
    t.index ["project_id"], :name => "index_contributions_on_project_id"
    t.index ["reward_id"], :name => "index_contributions_on_reward_id"
    t.index ["user_id"], :name => "index_contributions_on_user_id"
    t.foreign_key ["country_id"], "countries", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contributions_country_id"
    t.foreign_key ["donation_id"], "donations", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contributions_donation_id"
    t.foreign_key ["origin_id"], "origins", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_contributions_origin_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "contributions_project_id_reference"
    t.foreign_key ["reward_id"], "rewards", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "contributions_reward_id_reference"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "contributions_user_id_reference"
  end

  create_table "balance_transactions", force: true do |t|
    t.integer  "project_id"
    t.integer  "contribution_id"
    t.text     "event_name",               null: false
    t.integer  "user_id",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount",                   null: false
    t.integer  "balance_transfer_id"
    t.integer  "balance_transfer_ping_id"
    t.index ["balance_transfer_id"], :name => "fk__balance_transactions_balance_transfer_id"
    t.index ["balance_transfer_ping_id"], :name => "fk__balance_transactions_balance_transfer_ping_id"
    t.index ["contribution_id", "event_name", "user_id"], :name => "event_contribution_uidx", :unique => true
    t.index ["contribution_id"], :name => "fk__balance_transactions_contribution_id"
    t.index ["project_id", "event_name", "user_id"], :name => "event_project_uidx", :unique => true
    t.index ["project_id"], :name => "fk__balance_transactions_project_id"
    t.index ["user_id"], :name => "fk__balance_transactions_user_id"
    t.foreign_key ["balance_transfer_id"], "balance_transfers", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_balance_transactions_balance_transfer_id"
    t.foreign_key ["balance_transfer_ping_id"], "balance_transfer_pings", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_balance_transactions_balance_transfer_ping_id"
    t.foreign_key ["contribution_id"], "contributions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_balance_transactions_contribution_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_balance_transactions_project_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_balance_transactions_user_id"
  end

  create_table "balance_transfer_transitions", force: true do |t|
    t.string   "to_state",                         null: false
    t.json     "metadata",            default: {}
    t.integer  "sort_key",                         null: false
    t.integer  "balance_transfer_id",              null: false
    t.boolean  "most_recent",                      null: false
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["balance_transfer_id", "most_recent"], :name => "index_balance_transfer_transitions_parent_most_recent", :unique => true, :conditions => "most_recent"
    t.index ["balance_transfer_id", "sort_key"], :name => "index_balance_transfer_transitions_parent_sort", :unique => true
    t.index ["balance_transfer_id"], :name => "fk__balance_transfer_transitions_balance_transfer_id"
    t.foreign_key ["balance_transfer_id"], "balance_transfers", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_balance_transfer_transitions_balance_transfer_id"
  end

  create_table "banks", force: true do |t|
    t.text     "name",       null: false
    t.text     "code",       null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["code"], :name => "index_banks_on_code", :unique => true
  end

  create_table "bank_accounts", force: true do |t|
    t.integer  "user_id"
    t.text     "account",        null: false
    t.text     "agency",         null: false
    t.text     "owner_name",     null: false
    t.text     "owner_document", null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "account_digit",  null: false
    t.text     "agency_digit"
    t.integer  "bank_id",        null: false
    t.index ["bank_id"], :name => "fk__bank_accounts_bank_id"
    t.index ["user_id"], :name => "index_bank_accounts_on_user_id"
    t.foreign_key ["bank_id"], "banks", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_bank_accounts_bank_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_bank_accounts_user_id"
  end

  create_table "category_followers", force: true do |t|
    t.integer  "category_id", null: false
    t.integer  "user_id",     null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["category_id"], :name => "index_category_followers_on_category_id"
    t.index ["user_id"], :name => "index_category_followers_on_user_id"
    t.foreign_key ["category_id"], "categories", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_category_followers_category_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_category_followers_user_id"
  end

# Could not dump table "category_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

# Could not dump table "contribution_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

  create_table "credit_cards", force: true do |t|
    t.integer  "user_id"
    t.text     "last_digits",     null: false
    t.text     "card_brand",      null: false
    t.text     "subscription_id"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "card_key"
    t.index ["user_id"], :name => "index_credit_cards_on_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_credit_cards_user_id"
  end

  create_table "dbhero_dataclips", force: true do |t|
    t.text     "description",                 null: false
    t.text     "raw_query",                   null: false
    t.text     "token",                       null: false
    t.text     "user"
    t.boolean  "private",     default: false, null: false
    t.datetime "created_at", :default => { :expr => "now()" },                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["token"], :name => "index_dbhero_dataclips_on_token", :unique => true
    t.index ["user"], :name => "index_dbhero_dataclips_on_user"
  end

  create_table "deps_saved_ddl", primary_key: "deps_id", :default => { :expr => "nextval('deps_saved_ddl_deps_id_seq'::regclass)" }, force: true do |t|
    t.text "deps_view_schema"
    t.text "deps_view_name"
    t.text "deps_ddl_to_run"
  end

  create_table "direct_messages", force: true do |t|
    t.integer  "user_id"
    t.integer  "to_user_id", null: false
    t.integer  "project_id"
    t.text     "from_email", null: false
    t.text     "from_name"
    t.text     "content",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["project_id"], :name => "fk__direct_messages_project_id"
    t.index ["to_user_id"], :name => "fk__direct_messages_to_user_id"
    t.index ["user_id"], :name => "fk__direct_messages_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_direct_messages_project_id"
    t.foreign_key ["to_user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_direct_messages_to_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_direct_messages_user_id"
  end

# Could not dump table "direct_message_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

# Could not dump table "donation_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

  create_view "financial_reports", " SELECT p.name,\n    u.moip_login,\n    p.goal,\n    p.expires_at,\n    p.state\n   FROM (projects p\n     JOIN users u ON ((u.id = p.user_id)))", :force => true
# Could not dump table "moments" because of following StandardError
#   Unknown type 'jsonb' for column 'data'

  create_table "payment_logs", force: true do |t|
    t.string   "gateway_id", null: false
    t.json     "data",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["gateway_id"], :name => "index_payment_logs_on_gateway_id", :unique => true
  end

  create_table "payments", force: true do |t|
    t.integer  "contribution_id",               null: false
    t.text     "state",                         null: false
    t.text     "key",                           null: false
    t.text     "gateway",                       null: false
    t.text     "gateway_id"
    t.decimal  "gateway_fee"
    t.json     "gateway_data"
    t.text     "payment_method",                null: false
    t.decimal  "value",                         null: false
    t.integer  "installments",      default: 1, null: false
    t.decimal  "installment_value"
    t.datetime "paid_at"
    t.datetime "refused_at"
    t.datetime "pending_refund_at"
    t.datetime "refunded_at"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.tsvector "full_text_index"
    t.datetime "deleted_at"
    t.datetime "chargeback_at"
    t.text     "ip_address"
    t.index :name => "payment_created_at_z_uidx", :expression => "zone_timestamp(created_at)"
    t.index ["contribution_id"], :name => "fk__payments_contribution_id"
    t.index ["full_text_index"], :name => "payments_full_text_index_ix", :kind => "gin"
    t.index ["gateway_id", "gateway"], :name => "payments_gateway_id_gateway_idx", :unique => true
    t.index ["id"], :name => "payments_id_idx", :unique => true, :order => {"id" => :desc}
    t.index ["ip_address"], :name => "index_payments_on_ip_address"
    t.index ["key"], :name => "index_payments_on_key", :unique => true
    t.foreign_key ["contribution_id"], "contributions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_payments_contribution_id"
  end

  create_table "payment_notifications", force: true do |t|
    t.integer  "contribution_id", null: false
    t.text     "extra_data"
    t.datetime "created_at", :default => { :expr => "now()" },      null: false
    t.datetime "updated_at",      null: false
    t.integer  "payment_id"
    t.index ["contribution_id"], :name => "index_payment_notifications_on_contribution_id"
    t.index ["payment_id"], :name => "fk__payment_notifications_payment_id"
    t.foreign_key ["contribution_id"], "contributions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "payment_notifications_backer_id_fk"
    t.foreign_key ["payment_id"], "payments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_payment_notifications_payment_id"
  end

  create_table "payment_transfers", force: true do |t|
    t.integer  "user_id",       null: false
    t.integer  "payment_id",    null: false
    t.text     "transfer_id",   null: false
    t.json     "transfer_data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["payment_id"], :name => "fk__payment_transfers_payment_id"
    t.index ["user_id"], :name => "fk__payment_transfers_user_id"
    t.foreign_key ["payment_id"], "payments", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_payment_transfers_payment_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_payment_transfers_user_id"
  end

  create_table "paypal_payments", id: false, force: true do |t|
    t.text "data"
    t.text "hora"
    t.text "fusohorario"
    t.text "nome"
    t.text "tipo"
    t.text "status"
    t.text "moeda"
    t.text "valorbruto"
    t.text "tarifa"
    t.text "liquido"
    t.text "doe_mail"
    t.text "parae_mail"
    t.text "iddatransacao"
    t.text "statusdoequivalente"
    t.text "statusdoendereco"
    t.text "titulodoitem"
    t.text "iddoitem"
    t.text "valordoenvioemanuseio"
    t.text "valordoseguro"
    t.text "impostosobrevendas"
    t.text "opcao1nome"
    t.text "opcao1valor"
    t.text "opcao2nome"
    t.text "opcao2valor"
    t.text "sitedoleilao"
    t.text "iddocomprador"
    t.text "urldoitem"
    t.text "datadetermino"
    t.text "iddaescritura"
    t.text "iddafatura"
    t.text "idtxn_dereferência"
    t.text "numerodafatura"
    t.text "numeropersonalizado"
    t.text "iddorecibo"
    t.text "saldo"
    t.text "enderecolinha1"
    t.text "enderecolinha2_distrito_bairro"
    t.text "cidade"
    t.text "estado_regiao_território_prefeitura_republica"
    t.text "cep"
    t.text "pais"
    t.text "numerodotelefoneparacontato"
    t.text "extra"
  end

  create_table "project_accounts", force: true do |t|
    t.integer  "project_id",            null: false
    t.integer  "bank_id"
    t.text     "email",                 null: false
    t.text     "state_inscription"
    t.text     "address_street",        null: false
    t.text     "address_number",        null: false
    t.text     "address_complement"
    t.text     "address_city",          null: false
    t.text     "address_neighbourhood", null: false
    t.text     "address_state",         null: false
    t.text     "address_zip_code",      null: false
    t.text     "phone_number",          null: false
    t.text     "agency",                null: false
    t.text     "agency_digit",          null: false
    t.text     "account",               null: false
    t.text     "account_digit",         null: false
    t.text     "owner_name",            null: false
    t.text     "owner_document",        null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.text     "account_type"
    t.index ["bank_id"], :name => "fk__project_accounts_bank_id"
    t.index ["bank_id"], :name => "index_project_accounts_on_bank_id"
    t.index ["project_id"], :name => "index_project_accounts_on_project_id"
    t.foreign_key ["bank_id"], "banks", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_accounts_bank_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_accounts_project_id"
  end

  create_table "project_account_errors", force: true do |t|
    t.integer  "project_account_id",                 null: false
    t.text     "reason",                             null: false
    t.boolean  "solved",             default: false
    t.datetime "solved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_account_id"], :name => "fk__project_account_errors_project_account_id"
    t.foreign_key ["project_account_id"], "project_accounts", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_account_errors_project_account_id"
  end

  create_table "project_errors", force: true do |t|
    t.integer  "project_id", null: false
    t.text     "error"
    t.text     "to_state",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], :name => "fk__project_errors_project_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_errors_project_id"
  end

  create_table "settings", force: true do |t|
    t.text     "name",       null: false
    t.text     "value"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["name"], :name => "index_configurations_on_name", :unique => true
  end

  create_view "project_financials", " WITH catarse_fee_percentage AS (\n         SELECT (c.value)::numeric AS total,\n            ((1)::numeric - (c.value)::numeric) AS complement\n           FROM settings c\n          WHERE (c.name = 'catarse_fee'::text)\n        ), catarse_base_url AS (\n         SELECT c.value\n           FROM settings c\n          WHERE (c.name = 'base_url'::text)\n        )\n SELECT p.id AS project_id,\n    p.name,\n    u.moip_login AS moip,\n    p.goal,\n    pt.pledged AS reached,\n    pt.total_payment_service_fee AS payment_tax,\n    (cp.total * pt.pledged) AS catarse_fee,\n    (pt.pledged * cp.complement) AS repass_value,\n    to_char(timezone(COALESCE(( SELECT settings.value\n           FROM settings\n          WHERE (settings.name = 'timezone'::text)), 'America/Sao_Paulo'::text), p.expires_at), 'dd/mm/yyyy'::text) AS expires_at,\n    ((catarse_base_url.value || '/admin/reports/contribution_reports.csv?project_id='::text) || p.id) AS contribution_report,\n    p.state\n   FROM ((((projects p\n     JOIN users u ON ((u.id = p.user_id)))\n     LEFT JOIN \"1\".project_totals pt ON ((pt.project_id = p.id)))\n     CROSS JOIN catarse_fee_percentage cp)\n     CROSS JOIN catarse_base_url)", :force => true
# Could not dump table "project_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

  create_table "project_posts", force: true do |t|
    t.integer  "user_id",                      null: false
    t.integer  "project_id",                   null: false
    t.text     "title",                        null: false
    t.text     "comment_html",                 null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.boolean  "exclusive",    default: false
    t.index ["project_id"], :name => "index_updates_on_project_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "updates_project_id_fk"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "updates_user_id_fk"
  end

# Could not dump table "project_post_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

  create_table "project_reminders", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "project_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], :name => "fk__project_reminders_project_id"
    t.index ["user_id", "project_id"], :name => "index_project_reminders_on_user_id_and_project_id", :unique => true
    t.index ["user_id"], :name => "fk__project_reminders_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_reminders_project_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_reminders_user_id"
  end

  create_table "project_reports", force: true do |t|
    t.integer  "project_id", null: false
    t.integer  "user_id"
    t.text     "reason",     null: false
    t.text     "email"
    t.text     "details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["project_id"], :name => "fk__project_reports_project_id"
    t.index ["user_id"], :name => "fk__project_reports_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_reports_project_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_reports_user_id"
  end

# Could not dump table "project_report_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

  create_table "project_transitions", force: true do |t|
    t.string   "to_state",                   null: false
    t.text     "metadata",    default: "{}"
    t.integer  "sort_key",                   null: false
    t.integer  "project_id",                 null: false
    t.boolean  "most_recent",                null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["project_id", "sort_key"], :name => "index_project_transitions_parent_sort", :unique => true
    t.index ["project_id"], :name => "fk__project_transitions_project_id"
    t.index ["project_id"], :name => "project_transitions_project_id_idx", :conditions => "most_recent"
    t.index ["to_state"], :name => "to_state_project_tran_idx"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_project_transitions_project_id"
    t.foreign_key ["to_state"], "project_states", ["state"], :on_update => :no_action, :on_delete => :no_action, :name => "project_transitions_to_state_fkey"
  end

  create_view "projects_in_analysis_by_periods", " WITH weeks AS (\n         SELECT to_char(current_year_1.current_year, 'yyyy-mm W'::text) AS current_year,\n            to_char(last_year_1.last_year, 'yyyy-mm W'::text) AS last_year,\n            current_year_1.current_year AS label\n           FROM (generate_series((now() - '49 days'::interval), now(), '7 days'::interval) current_year_1(current_year)\n             JOIN generate_series((now() - '1 year 49 days'::interval), (now() - '1 year'::interval), '7 days'::interval) last_year_1(last_year) ON ((to_char(last_year_1.last_year, 'mm W'::text) = to_char(current_year_1.current_year, 'mm W'::text))))\n        ), current_year AS (\n         SELECT w.label,\n            count(*) AS current_year\n           FROM (projects p\n             JOIN weeks w ON ((w.current_year = to_char(in_analysis_at(p.*), 'yyyy-mm W'::text))))\n          GROUP BY w.label\n        ), last_year AS (\n         SELECT w.label,\n            count(*) AS last_year\n           FROM (projects p\n             JOIN weeks w ON ((w.last_year = to_char(in_analysis_at(p.*), 'yyyy-mm W'::text))))\n          GROUP BY w.label\n        )\n SELECT current_year.label,\n    current_year.current_year,\n    last_year.last_year\n   FROM (current_year\n     JOIN last_year USING (label))", :force => true
  create_table "public_tags", force: true do |t|
    t.text     "name",       null: false
    t.text     "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], :name => "index_public_tags_on_slug", :unique => true
  end

  create_table "rdevents", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "project_id"
    t.text     "event_name", null: false
    t.json     "metadata"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["project_id"], :name => "fk__rdevents_project_id"
    t.index ["user_id"], :name => "fk__rdevents_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_rdevents_project_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_rdevents_user_id"
  end

  create_table "redactor_assets", force: true do |t|
    t.integer  "user_id"
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["assetable_type", "assetable_id"], :name => "idx_redactor_assetable"
    t.index ["assetable_type", "type", "assetable_id"], :name => "idx_redactor_assetable_type"
    t.index ["user_id"], :name => "fk__redactor_assets_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_redactor_assets_user_id"
  end

  create_table "sendgrid_events", force: true do |t|
    t.integer  "notification_id",   null: false
    t.integer  "notification_user", null: false
    t.text     "notification_type", null: false
    t.text     "template_name",     null: false
    t.text     "event",             null: false
    t.text     "email",             null: false
    t.text     "useragent"
    t.json     "sendgrid_data",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.text     "name",       null: false
    t.text     "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["slug"], :name => "index_tags_on_slug", :unique => true
  end

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "project_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "public_tag_id"
    t.index ["project_id"], :name => "fk__taggings_project_id"
    t.index ["public_tag_id", "project_id"], :name => "index_taggings_on_public_tag_id_and_project_id", :unique => true
    t.index ["public_tag_id"], :name => "fk__taggings_public_tag_id"
    t.index ["tag_id", "project_id"], :name => "index_taggings_on_tag_id_and_project_id", :unique => true
    t.index ["tag_id"], :name => "fk__taggings_tag_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_taggings_project_id"
    t.foreign_key ["public_tag_id"], "public_tags", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_taggings_public_tag_id"
    t.foreign_key ["tag_id"], "tags", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_taggings_tag_id"
  end

  create_table "total_backed_ranges", primary_key: "name", force: true do |t|
    t.decimal "lower"
    t.decimal "upper"
  end

  create_table "unsubscribes", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "project_id", null: false
    t.datetime "created_at", :default => { :expr => "now()" }, null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], :name => "index_unsubscribes_on_project_id"
    t.index ["user_id"], :name => "index_unsubscribes_on_user_id"
    t.foreign_key ["project_id"], "projects", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "unsubscribes_project_id_fk"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "unsubscribes_user_id_fk"
  end

  create_table "user_follows", force: true do |t|
    t.integer  "user_id"
    t.integer  "follow_id"
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["follow_id"], :name => "index_user_follows_on_follow_id"
    t.index ["user_id", "follow_id"], :name => "user_follow_uidx", :unique => true
    t.index ["user_id"], :name => "index_user_follows_on_user_id"
    t.foreign_key ["follow_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "ufollowfk"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_follows_user_id"
  end

# Could not dump table "user_follow_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

  create_table "user_friends", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["friend_id"], :name => "fk__user_friends_friend_id"
    t.index ["user_id", "friend_id"], :name => "index_user_friends_on_user_id_and_friend_id", :unique => true
    t.index ["user_id"], :name => "fk__user_friends_user_id"
    t.foreign_key ["friend_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_friends_friend_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_friends_user_id"
  end

  create_table "user_links", force: true do |t|
    t.text     "link",       null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", :default => { :expr => "now()" }
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__user_links_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_links_user_id"
  end

# Could not dump table "user_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

  create_table "user_transfers", force: true do |t|
    t.text     "status",        null: false
    t.integer  "amount",        null: false
    t.integer  "user_id",       null: false
    t.json     "transfer_data"
    t.integer  "gateway_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], :name => "fk__user_transfers_user_id"
    t.foreign_key ["user_id"], "users", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_user_transfers_user_id"
  end

# Could not dump table "user_transfer_notifications" because of following StandardError
#   Unknown type 'jsonb' for column 'metadata'

end
