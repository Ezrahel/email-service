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

ActiveRecord::Schema[8.1].define(version: 2024_01_01_000030) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  create_table "aggregates", primary_key: ["id", "bucket"], options: "PARTITION BY RANGE (bucket)", force: :cascade do |t|
    t.decimal "avg_delivery_latency_ms", precision: 10, scale: 2
    t.decimal "bounce_rate", precision: 5, scale: 4
    t.bigint "bounced_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "click_rate", precision: 5, scale: 4
    t.bigint "clicked_count", default: 0, null: false
    t.bigint "complained_count", default: 0, null: false
    t.decimal "complaint_rate", precision: 5, scale: 4
    t.timestamptz "created_at", null: false
    t.bigint "delivered_count", default: 0, null: false
    t.decimal "delivery_rate", precision: 5, scale: 4
    t.bigint "failed_count", default: 0, null: false
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "metric_name", null: false
    t.decimal "open_rate", precision: 5, scale: 4
    t.bigint "opened_count", default: 0, null: false
    t.uuid "organization_id", null: false
    t.decimal "p50_latency_ms", precision: 10, scale: 2
    t.decimal "p90_latency_ms", precision: 10, scale: 2
    t.decimal "p99_latency_ms", precision: 10, scale: 2
    t.bigint "queued_count", default: 0, null: false
    t.bigint "total_count", default: 0, null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "index_aggregates_on_bucket"
    t.index ["organization_id", "granularity", "bucket"], name: "index_aggregates_on_organization_id_and_granularity_and_bucket"
    t.index ["organization_id", "metric_name", "granularity", "bucket"], name: "idx_aggregates_unique_bucket", unique: true
  end

  create_table "aggregates_202401", primary_key: ["id", "bucket"], options: "INHERITS (aggregates)", force: :cascade do |t|
    t.decimal "avg_delivery_latency_ms", precision: 10, scale: 2
    t.decimal "bounce_rate", precision: 5, scale: 4
    t.bigint "bounced_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "click_rate", precision: 5, scale: 4
    t.bigint "clicked_count", default: 0, null: false
    t.bigint "complained_count", default: 0, null: false
    t.decimal "complaint_rate", precision: 5, scale: 4
    t.timestamptz "created_at", null: false
    t.bigint "delivered_count", default: 0, null: false
    t.decimal "delivery_rate", precision: 5, scale: 4
    t.bigint "failed_count", default: 0, null: false
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "metric_name", null: false
    t.decimal "open_rate", precision: 5, scale: 4
    t.bigint "opened_count", default: 0, null: false
    t.uuid "organization_id", null: false
    t.decimal "p50_latency_ms", precision: 10, scale: 2
    t.decimal "p90_latency_ms", precision: 10, scale: 2
    t.decimal "p99_latency_ms", precision: 10, scale: 2
    t.bigint "queued_count", default: 0, null: false
    t.bigint "total_count", default: 0, null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "aggregates_202401_bucket_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "aggregates_202401_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric_name", "granularity", "bucket"], name: "aggregates_202401_organization_id_metric_name_granularity_b_idx", unique: true
  end

  create_table "aggregates_202404", primary_key: ["id", "bucket"], options: "INHERITS (aggregates)", force: :cascade do |t|
    t.decimal "avg_delivery_latency_ms", precision: 10, scale: 2
    t.decimal "bounce_rate", precision: 5, scale: 4
    t.bigint "bounced_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "click_rate", precision: 5, scale: 4
    t.bigint "clicked_count", default: 0, null: false
    t.bigint "complained_count", default: 0, null: false
    t.decimal "complaint_rate", precision: 5, scale: 4
    t.timestamptz "created_at", null: false
    t.bigint "delivered_count", default: 0, null: false
    t.decimal "delivery_rate", precision: 5, scale: 4
    t.bigint "failed_count", default: 0, null: false
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "metric_name", null: false
    t.decimal "open_rate", precision: 5, scale: 4
    t.bigint "opened_count", default: 0, null: false
    t.uuid "organization_id", null: false
    t.decimal "p50_latency_ms", precision: 10, scale: 2
    t.decimal "p90_latency_ms", precision: 10, scale: 2
    t.decimal "p99_latency_ms", precision: 10, scale: 2
    t.bigint "queued_count", default: 0, null: false
    t.bigint "total_count", default: 0, null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "aggregates_202404_bucket_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "aggregates_202404_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric_name", "granularity", "bucket"], name: "aggregates_202404_organization_id_metric_name_granularity_b_idx", unique: true
  end

  create_table "aggregates_202407", primary_key: ["id", "bucket"], options: "INHERITS (aggregates)", force: :cascade do |t|
    t.decimal "avg_delivery_latency_ms", precision: 10, scale: 2
    t.decimal "bounce_rate", precision: 5, scale: 4
    t.bigint "bounced_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "click_rate", precision: 5, scale: 4
    t.bigint "clicked_count", default: 0, null: false
    t.bigint "complained_count", default: 0, null: false
    t.decimal "complaint_rate", precision: 5, scale: 4
    t.timestamptz "created_at", null: false
    t.bigint "delivered_count", default: 0, null: false
    t.decimal "delivery_rate", precision: 5, scale: 4
    t.bigint "failed_count", default: 0, null: false
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "metric_name", null: false
    t.decimal "open_rate", precision: 5, scale: 4
    t.bigint "opened_count", default: 0, null: false
    t.uuid "organization_id", null: false
    t.decimal "p50_latency_ms", precision: 10, scale: 2
    t.decimal "p90_latency_ms", precision: 10, scale: 2
    t.decimal "p99_latency_ms", precision: 10, scale: 2
    t.bigint "queued_count", default: 0, null: false
    t.bigint "total_count", default: 0, null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "aggregates_202407_bucket_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "aggregates_202407_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric_name", "granularity", "bucket"], name: "aggregates_202407_organization_id_metric_name_granularity_b_idx", unique: true
  end

  create_table "aggregates_202410", primary_key: ["id", "bucket"], options: "INHERITS (aggregates)", force: :cascade do |t|
    t.decimal "avg_delivery_latency_ms", precision: 10, scale: 2
    t.decimal "bounce_rate", precision: 5, scale: 4
    t.bigint "bounced_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "click_rate", precision: 5, scale: 4
    t.bigint "clicked_count", default: 0, null: false
    t.bigint "complained_count", default: 0, null: false
    t.decimal "complaint_rate", precision: 5, scale: 4
    t.timestamptz "created_at", null: false
    t.bigint "delivered_count", default: 0, null: false
    t.decimal "delivery_rate", precision: 5, scale: 4
    t.bigint "failed_count", default: 0, null: false
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "metric_name", null: false
    t.decimal "open_rate", precision: 5, scale: 4
    t.bigint "opened_count", default: 0, null: false
    t.uuid "organization_id", null: false
    t.decimal "p50_latency_ms", precision: 10, scale: 2
    t.decimal "p90_latency_ms", precision: 10, scale: 2
    t.decimal "p99_latency_ms", precision: 10, scale: 2
    t.bigint "queued_count", default: 0, null: false
    t.bigint "total_count", default: 0, null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "aggregates_202410_bucket_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "aggregates_202410_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric_name", "granularity", "bucket"], name: "aggregates_202410_organization_id_metric_name_granularity_b_idx", unique: true
  end

  create_table "api_keys", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.jsonb "allowed_ips", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "expires_at"
    t.string "key_digest", null: false
    t.string "key_last_chars", null: false
    t.string "key_prefix", null: false
    t.datetime "last_used_at"
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.datetime "revoked_at"
    t.jsonb "scopes", default: [], null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["deleted_at"], name: "index_api_keys_on_deleted_at"
    t.index ["key_digest"], name: "index_api_keys_on_key_digest", unique: true
    t.index ["key_prefix"], name: "index_api_keys_on_key_prefix"
    t.index ["organization_id", "status"], name: "index_api_keys_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_api_keys_on_organization_id"
    t.index ["status"], name: "index_api_keys_on_status"
    t.index ["user_id"], name: "index_api_keys_on_user_id"
  end

  create_table "attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "byte_size", null: false
    t.string "content_id"
    t.string "content_type", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.uuid "email_message_id", null: false
    t.string "filename", null: false
    t.boolean "is_inline", default: false, null: false
    t.string "s3_bucket", null: false
    t.string "s3_key", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_attachments_on_deleted_at"
    t.index ["email_message_id"], name: "index_attachments_on_email_message_id"
    t.index ["s3_key"], name: "index_attachments_on_s3_key", unique: true
  end

  create_table "audit_logs", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["deleted_at"], name: "index_audit_logs_on_deleted_at"
    t.index ["event_timestamp"], name: "index_audit_logs_on_event_timestamp"
    t.index ["organization_id", "event_timestamp"], name: "index_audit_logs_on_organization_id_and_event_timestamp"
    t.index ["organization_id"], name: "index_audit_logs_on_organization_id"
    t.index ["request_id"], name: "index_audit_logs_on_request_id"
    t.index ["resource_type", "resource_id"], name: "index_audit_logs_on_resource_type_and_resource_id"
    t.index ["resource_type"], name: "index_audit_logs_on_resource_type"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "audit_logs_202401", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202401_action_idx"
    t.index ["created_at"], name: "audit_logs_202401_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202401_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202401_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202401_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202401_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202401_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202401_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202401_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202401_user_id_idx"
  end

  create_table "audit_logs_202404", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202404_action_idx"
    t.index ["created_at"], name: "audit_logs_202404_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202404_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202404_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202404_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202404_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202404_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202404_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202404_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202404_user_id_idx"
  end

  create_table "audit_logs_202407", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202407_action_idx"
    t.index ["created_at"], name: "audit_logs_202407_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202407_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202407_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202407_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202407_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202407_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202407_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202407_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202407_user_id_idx"
  end

  create_table "audit_logs_202410", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202410_action_idx"
    t.index ["created_at"], name: "audit_logs_202410_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202410_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202410_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202410_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202410_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202410_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202410_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202410_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202410_user_id_idx"
  end

  create_table "audit_logs_202501", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202501_action_idx"
    t.index ["created_at"], name: "audit_logs_202501_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202501_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202501_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202501_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202501_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202501_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202501_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202501_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202501_user_id_idx"
  end

  create_table "audit_logs_202502", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202502_action_idx"
    t.index ["created_at"], name: "audit_logs_202502_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202502_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202502_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202502_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202502_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202502_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202502_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202502_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202502_user_id_idx"
  end

  create_table "audit_logs_202503", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202503_action_idx"
    t.index ["created_at"], name: "audit_logs_202503_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202503_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202503_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202503_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202503_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202503_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202503_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202503_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202503_user_id_idx"
  end

  create_table "audit_logs_202504", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202504_action_idx"
    t.index ["created_at"], name: "audit_logs_202504_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202504_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202504_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202504_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202504_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202504_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202504_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202504_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202504_user_id_idx"
  end

  create_table "audit_logs_202505", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202505_action_idx"
    t.index ["created_at"], name: "audit_logs_202505_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202505_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202505_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202505_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202505_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202505_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202505_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202505_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202505_user_id_idx"
  end

  create_table "audit_logs_202506", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202506_action_idx"
    t.index ["created_at"], name: "audit_logs_202506_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202506_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202506_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202506_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202506_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202506_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202506_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202506_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202506_user_id_idx"
  end

  create_table "audit_logs_202507", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202507_action_idx"
    t.index ["created_at"], name: "audit_logs_202507_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202507_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202507_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202507_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202507_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202507_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202507_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202507_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202507_user_id_idx"
  end

  create_table "audit_logs_202508", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202508_action_idx"
    t.index ["created_at"], name: "audit_logs_202508_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202508_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202508_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202508_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202508_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202508_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202508_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202508_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202508_user_id_idx"
  end

  create_table "audit_logs_202509", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202509_action_idx"
    t.index ["created_at"], name: "audit_logs_202509_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202509_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202509_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202509_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202509_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202509_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202509_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202509_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202509_user_id_idx"
  end

  create_table "audit_logs_202510", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202510_action_idx"
    t.index ["created_at"], name: "audit_logs_202510_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202510_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202510_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202510_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202510_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202510_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202510_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202510_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202510_user_id_idx"
  end

  create_table "audit_logs_202511", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202511_action_idx"
    t.index ["created_at"], name: "audit_logs_202511_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202511_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202511_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202511_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202511_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202511_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202511_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202511_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202511_user_id_idx"
  end

  create_table "audit_logs_202512", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202512_action_idx"
    t.index ["created_at"], name: "audit_logs_202512_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202512_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202512_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202512_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202512_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202512_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202512_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202512_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202512_user_id_idx"
  end

  create_table "audit_logs_202601", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202601_action_idx"
    t.index ["created_at"], name: "audit_logs_202601_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202601_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202601_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202601_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202601_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202601_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202601_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202601_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202601_user_id_idx"
  end

  create_table "audit_logs_202602", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202602_action_idx"
    t.index ["created_at"], name: "audit_logs_202602_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202602_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202602_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202602_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202602_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202602_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202602_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202602_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202602_user_id_idx"
  end

  create_table "audit_logs_202603", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202603_action_idx"
    t.index ["created_at"], name: "audit_logs_202603_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202603_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202603_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202603_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202603_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202603_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202603_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202603_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202603_user_id_idx"
  end

  create_table "audit_logs_202604", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202604_action_idx"
    t.index ["created_at"], name: "audit_logs_202604_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202604_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202604_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202604_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202604_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202604_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202604_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202604_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202604_user_id_idx"
  end

  create_table "audit_logs_202605", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202605_action_idx"
    t.index ["created_at"], name: "audit_logs_202605_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202605_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202605_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202605_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202605_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202605_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202605_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202605_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202605_user_id_idx"
  end

  create_table "audit_logs_202606", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202606_action_idx"
    t.index ["created_at"], name: "audit_logs_202606_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202606_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202606_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202606_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202606_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202606_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202606_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202606_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202606_user_id_idx"
  end

  create_table "audit_logs_202607", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202607_action_idx"
    t.index ["created_at"], name: "audit_logs_202607_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202607_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202607_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202607_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202607_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202607_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202607_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202607_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202607_user_id_idx"
  end

  create_table "audit_logs_202608", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202608_action_idx"
    t.index ["created_at"], name: "audit_logs_202608_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202608_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202608_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202608_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202608_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202608_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202608_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202608_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202608_user_id_idx"
  end

  create_table "audit_logs_202609", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202609_action_idx"
    t.index ["created_at"], name: "audit_logs_202609_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202609_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202609_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202609_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202609_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202609_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202609_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202609_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202609_user_id_idx"
  end

  create_table "audit_logs_202610", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202610_action_idx"
    t.index ["created_at"], name: "audit_logs_202610_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202610_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202610_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202610_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202610_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202610_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202610_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202610_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202610_user_id_idx"
  end

  create_table "audit_logs_202611", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202611_action_idx"
    t.index ["created_at"], name: "audit_logs_202611_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202611_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202611_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202611_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202611_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202611_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202611_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202611_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202611_user_id_idx"
  end

  create_table "audit_logs_202612", primary_key: ["id", "created_at"], options: "INHERITS (audit_logs)", force: :cascade do |t|
    t.string "action", null: false
    t.uuid "api_key_id"
    t.jsonb "changes", default: {}, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id"
    t.string "request_id"
    t.uuid "resource_id"
    t.string "resource_type", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id"
    t.index ["action"], name: "audit_logs_202612_action_idx"
    t.index ["created_at"], name: "audit_logs_202612_created_at_idx"
    t.index ["deleted_at"], name: "audit_logs_202612_deleted_at_idx"
    t.index ["event_timestamp"], name: "audit_logs_202612_event_timestamp_idx"
    t.index ["organization_id", "event_timestamp"], name: "audit_logs_202612_organization_id_event_timestamp_idx"
    t.index ["organization_id"], name: "audit_logs_202612_organization_id_idx"
    t.index ["request_id"], name: "audit_logs_202612_request_id_idx"
    t.index ["resource_type", "resource_id"], name: "audit_logs_202612_resource_type_resource_id_idx"
    t.index ["resource_type"], name: "audit_logs_202612_resource_type_idx"
    t.index ["user_id"], name: "audit_logs_202612_user_id_idx"
  end

  create_table "deliveries", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "index_deliveries_on_created_at"
    t.index ["deleted_at"], name: "index_deliveries_on_deleted_at"
    t.index ["email_message_id"], name: "index_deliveries_on_email_message_id"
    t.index ["organization_id", "created_at"], name: "index_deliveries_on_organization_id_and_created_at"
    t.index ["organization_id", "status"], name: "index_deliveries_on_organization_id_and_status"
    t.index ["organization_id"], name: "index_deliveries_on_organization_id"
    t.index ["provider"], name: "index_deliveries_on_provider"
    t.index ["provider_message_id"], name: "index_deliveries_on_provider_message_id", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "index_deliveries_on_status"
  end

  create_table "deliveries_202401", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202401_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202401_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202401_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202401_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202401_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202401_organization_id_idx"
    t.index ["provider"], name: "deliveries_202401_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202401_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202401_status_idx"
  end

  create_table "deliveries_202402", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202402_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202402_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202402_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202402_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202402_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202402_organization_id_idx"
    t.index ["provider"], name: "deliveries_202402_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202402_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202402_status_idx"
  end

  create_table "deliveries_202403", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202403_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202403_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202403_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202403_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202403_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202403_organization_id_idx"
    t.index ["provider"], name: "deliveries_202403_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202403_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202403_status_idx"
  end

  create_table "deliveries_202404", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202404_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202404_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202404_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202404_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202404_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202404_organization_id_idx"
    t.index ["provider"], name: "deliveries_202404_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202404_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202404_status_idx"
  end

  create_table "deliveries_202405", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202405_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202405_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202405_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202405_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202405_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202405_organization_id_idx"
    t.index ["provider"], name: "deliveries_202405_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202405_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202405_status_idx"
  end

  create_table "deliveries_202406", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202406_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202406_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202406_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202406_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202406_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202406_organization_id_idx"
    t.index ["provider"], name: "deliveries_202406_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202406_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202406_status_idx"
  end

  create_table "deliveries_202407", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202407_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202407_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202407_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202407_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202407_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202407_organization_id_idx"
    t.index ["provider"], name: "deliveries_202407_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202407_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202407_status_idx"
  end

  create_table "deliveries_202408", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202408_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202408_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202408_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202408_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202408_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202408_organization_id_idx"
    t.index ["provider"], name: "deliveries_202408_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202408_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202408_status_idx"
  end

  create_table "deliveries_202409", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202409_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202409_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202409_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202409_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202409_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202409_organization_id_idx"
    t.index ["provider"], name: "deliveries_202409_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202409_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202409_status_idx"
  end

  create_table "deliveries_202410", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202410_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202410_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202410_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202410_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202410_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202410_organization_id_idx"
    t.index ["provider"], name: "deliveries_202410_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202410_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202410_status_idx"
  end

  create_table "deliveries_202411", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202411_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202411_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202411_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202411_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202411_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202411_organization_id_idx"
    t.index ["provider"], name: "deliveries_202411_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202411_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202411_status_idx"
  end

  create_table "deliveries_202412", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202412_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202412_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202412_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202412_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202412_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202412_organization_id_idx"
    t.index ["provider"], name: "deliveries_202412_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202412_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202412_status_idx"
  end

  create_table "deliveries_202501", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202501_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202501_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202501_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202501_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202501_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202501_organization_id_idx"
    t.index ["provider"], name: "deliveries_202501_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202501_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202501_status_idx"
  end

  create_table "deliveries_202502", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202502_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202502_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202502_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202502_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202502_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202502_organization_id_idx"
    t.index ["provider"], name: "deliveries_202502_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202502_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202502_status_idx"
  end

  create_table "deliveries_202503", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202503_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202503_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202503_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202503_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202503_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202503_organization_id_idx"
    t.index ["provider"], name: "deliveries_202503_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202503_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202503_status_idx"
  end

  create_table "deliveries_202504", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202504_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202504_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202504_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202504_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202504_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202504_organization_id_idx"
    t.index ["provider"], name: "deliveries_202504_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202504_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202504_status_idx"
  end

  create_table "deliveries_202505", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202505_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202505_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202505_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202505_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202505_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202505_organization_id_idx"
    t.index ["provider"], name: "deliveries_202505_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202505_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202505_status_idx"
  end

  create_table "deliveries_202506", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202506_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202506_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202506_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202506_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202506_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202506_organization_id_idx"
    t.index ["provider"], name: "deliveries_202506_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202506_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202506_status_idx"
  end

  create_table "deliveries_202507", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202507_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202507_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202507_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202507_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202507_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202507_organization_id_idx"
    t.index ["provider"], name: "deliveries_202507_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202507_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202507_status_idx"
  end

  create_table "deliveries_202508", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202508_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202508_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202508_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202508_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202508_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202508_organization_id_idx"
    t.index ["provider"], name: "deliveries_202508_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202508_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202508_status_idx"
  end

  create_table "deliveries_202509", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202509_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202509_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202509_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202509_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202509_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202509_organization_id_idx"
    t.index ["provider"], name: "deliveries_202509_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202509_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202509_status_idx"
  end

  create_table "deliveries_202510", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202510_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202510_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202510_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202510_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202510_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202510_organization_id_idx"
    t.index ["provider"], name: "deliveries_202510_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202510_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202510_status_idx"
  end

  create_table "deliveries_202511", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202511_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202511_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202511_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202511_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202511_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202511_organization_id_idx"
    t.index ["provider"], name: "deliveries_202511_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202511_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202511_status_idx"
  end

  create_table "deliveries_202512", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202512_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202512_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202512_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202512_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202512_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202512_organization_id_idx"
    t.index ["provider"], name: "deliveries_202512_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202512_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202512_status_idx"
  end

  create_table "deliveries_202601", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202601_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202601_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202601_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202601_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202601_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202601_organization_id_idx"
    t.index ["provider"], name: "deliveries_202601_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202601_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202601_status_idx"
  end

  create_table "deliveries_202602", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202602_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202602_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202602_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202602_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202602_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202602_organization_id_idx"
    t.index ["provider"], name: "deliveries_202602_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202602_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202602_status_idx"
  end

  create_table "deliveries_202603", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202603_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202603_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202603_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202603_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202603_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202603_organization_id_idx"
    t.index ["provider"], name: "deliveries_202603_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202603_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202603_status_idx"
  end

  create_table "deliveries_202604", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202604_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202604_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202604_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202604_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202604_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202604_organization_id_idx"
    t.index ["provider"], name: "deliveries_202604_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202604_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202604_status_idx"
  end

  create_table "deliveries_202605", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202605_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202605_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202605_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202605_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202605_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202605_organization_id_idx"
    t.index ["provider"], name: "deliveries_202605_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202605_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202605_status_idx"
  end

  create_table "deliveries_202606", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202606_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202606_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202606_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202606_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202606_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202606_organization_id_idx"
    t.index ["provider"], name: "deliveries_202606_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202606_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202606_status_idx"
  end

  create_table "deliveries_202607", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202607_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202607_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202607_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202607_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202607_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202607_organization_id_idx"
    t.index ["provider"], name: "deliveries_202607_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202607_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202607_status_idx"
  end

  create_table "deliveries_202608", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202608_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202608_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202608_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202608_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202608_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202608_organization_id_idx"
    t.index ["provider"], name: "deliveries_202608_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202608_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202608_status_idx"
  end

  create_table "deliveries_202609", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202609_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202609_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202609_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202609_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202609_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202609_organization_id_idx"
    t.index ["provider"], name: "deliveries_202609_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202609_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202609_status_idx"
  end

  create_table "deliveries_202610", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202610_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202610_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202610_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202610_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202610_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202610_organization_id_idx"
    t.index ["provider"], name: "deliveries_202610_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202610_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202610_status_idx"
  end

  create_table "deliveries_202611", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202611_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202611_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202611_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202611_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202611_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202611_organization_id_idx"
    t.index ["provider"], name: "deliveries_202611_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202611_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202611_status_idx"
  end

  create_table "deliveries_202612", primary_key: ["id", "created_at"], options: "INHERITS (deliveries)", force: :cascade do |t|
    t.integer "attempt_count", default: 0, null: false
    t.string "bounce_classification"
    t.string "bounce_type"
    t.timestamptz "bounced_at"
    t.integer "click_count", default: 0, null: false
    t.timestamptz "clicked_at"
    t.timestamptz "complaint_at"
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "email_message_id", null: false
    t.string "failure_code"
    t.string "failure_reason"
    t.timestamptz "first_attempt_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.timestamptz "last_attempt_at"
    t.integer "last_attempt_duration_ms"
    t.integer "max_attempts", default: 3, null: false
    t.integer "open_count", default: 0, null: false
    t.timestamptz "opened_at"
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.uuid "provider_config_id"
    t.string "provider_message_id"
    t.jsonb "provider_response", default: {}, null: false
    t.decimal "provider_score", precision: 5, scale: 2
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "deliveries_202612_created_at_idx"
    t.index ["deleted_at"], name: "deliveries_202612_deleted_at_idx"
    t.index ["email_message_id"], name: "deliveries_202612_email_message_id_idx"
    t.index ["organization_id", "created_at"], name: "deliveries_202612_organization_id_created_at_idx"
    t.index ["organization_id", "status"], name: "deliveries_202612_organization_id_status_idx"
    t.index ["organization_id"], name: "deliveries_202612_organization_id_idx"
    t.index ["provider"], name: "deliveries_202612_provider_idx"
    t.index ["provider_message_id"], name: "deliveries_202612_provider_message_id_idx", where: "(provider_message_id IS NOT NULL)"
    t.index ["status"], name: "deliveries_202612_status_idx"
  end

  create_table "delivery_events", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "index_delivery_events_on_created_at"
    t.index ["deleted_at"], name: "index_delivery_events_on_deleted_at"
    t.index ["delivery_id"], name: "index_delivery_events_on_delivery_id"
    t.index ["email_message_id"], name: "index_delivery_events_on_email_message_id"
    t.index ["event_timestamp"], name: "index_delivery_events_on_event_timestamp"
    t.index ["event_type"], name: "index_delivery_events_on_event_type"
    t.index ["organization_id", "event_timestamp"], name: "index_delivery_events_on_organization_id_and_event_timestamp"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "idx_on_organization_id_event_type_event_timestamp_9ff68cfa60"
    t.index ["processed_at"], name: "index_delivery_events_on_processed_at", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "index_delivery_events_on_provider"
    t.index ["provider_event_id"], name: "index_delivery_events_on_provider_event_id", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202401", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202401_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202401_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202401_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202401_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202401_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202401_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202401_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202401_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202401_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202401_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202401_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202402", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202402_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202402_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202402_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202402_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202402_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202402_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202402_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202402_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202402_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202402_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202402_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202403", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202403_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202403_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202403_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202403_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202403_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202403_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202403_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202403_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202403_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202403_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202403_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202404", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202404_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202404_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202404_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202404_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202404_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202404_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202404_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202404_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202404_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202404_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202404_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202405", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202405_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202405_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202405_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202405_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202405_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202405_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202405_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202405_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202405_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202405_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202405_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202406", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202406_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202406_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202406_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202406_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202406_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202406_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202406_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202406_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202406_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202406_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202406_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202407", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202407_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202407_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202407_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202407_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202407_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202407_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202407_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202407_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202407_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202407_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202407_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202408", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202408_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202408_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202408_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202408_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202408_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202408_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202408_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202408_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202408_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202408_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202408_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202409", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202409_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202409_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202409_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202409_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202409_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202409_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202409_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202409_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202409_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202409_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202409_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202410", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202410_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202410_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202410_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202410_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202410_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202410_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202410_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202410_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202410_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202410_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202410_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202411", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202411_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202411_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202411_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202411_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202411_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202411_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202411_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202411_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202411_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202411_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202411_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202412", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202412_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202412_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202412_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202412_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202412_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202412_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202412_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202412_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202412_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202412_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202412_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202501", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202501_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202501_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202501_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202501_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202501_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202501_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202501_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202501_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202501_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202501_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202501_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202502", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202502_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202502_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202502_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202502_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202502_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202502_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202502_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202502_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202502_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202502_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202502_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202503", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202503_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202503_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202503_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202503_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202503_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202503_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202503_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202503_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202503_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202503_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202503_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202504", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202504_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202504_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202504_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202504_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202504_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202504_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202504_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202504_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202504_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202504_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202504_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202505", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202505_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202505_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202505_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202505_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202505_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202505_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202505_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202505_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202505_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202505_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202505_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202506", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202506_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202506_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202506_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202506_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202506_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202506_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202506_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202506_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202506_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202506_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202506_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202507", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202507_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202507_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202507_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202507_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202507_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202507_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202507_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202507_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202507_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202507_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202507_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202508", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202508_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202508_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202508_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202508_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202508_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202508_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202508_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202508_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202508_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202508_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202508_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202509", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202509_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202509_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202509_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202509_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202509_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202509_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202509_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202509_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202509_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202509_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202509_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202510", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202510_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202510_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202510_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202510_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202510_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202510_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202510_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202510_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202510_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202510_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202510_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202511", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202511_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202511_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202511_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202511_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202511_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202511_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202511_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202511_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202511_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202511_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202511_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202512", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202512_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202512_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202512_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202512_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202512_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202512_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202512_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202512_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202512_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202512_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202512_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202601", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202601_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202601_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202601_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202601_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202601_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202601_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202601_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202601_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202601_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202601_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202601_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202602", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202602_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202602_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202602_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202602_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202602_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202602_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202602_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202602_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202602_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202602_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202602_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202603", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202603_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202603_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202603_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202603_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202603_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202603_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202603_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202603_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202603_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202603_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202603_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202604", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202604_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202604_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202604_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202604_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202604_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202604_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202604_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202604_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202604_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202604_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202604_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202605", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202605_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202605_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202605_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202605_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202605_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202605_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202605_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202605_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202605_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202605_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202605_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202606", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202606_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202606_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202606_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202606_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202606_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202606_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202606_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202606_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202606_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202606_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202606_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202607", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202607_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202607_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202607_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202607_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202607_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202607_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202607_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202607_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202607_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202607_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202607_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202608", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202608_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202608_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202608_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202608_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202608_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202608_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202608_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202608_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202608_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202608_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202608_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202609", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202609_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202609_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202609_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202609_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202609_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202609_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202609_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202609_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202609_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202609_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202609_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202610", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202610_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202610_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202610_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202610_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202610_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202610_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202610_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202610_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202610_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202610_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202610_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202611", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202611_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202611_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202611_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202611_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202611_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202611_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202611_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202611_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202611_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202611_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202611_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "delivery_events_202612", primary_key: ["id", "created_at"], options: "INHERITS (delivery_events)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.uuid "email_message_id", null: false
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.timestamptz "processed_at"
    t.string "provider", null: false
    t.string "provider_event_id"
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "delivery_events_202612_created_at_idx"
    t.index ["deleted_at"], name: "delivery_events_202612_deleted_at_idx"
    t.index ["delivery_id"], name: "delivery_events_202612_delivery_id_idx"
    t.index ["email_message_id"], name: "delivery_events_202612_email_message_id_idx"
    t.index ["event_timestamp"], name: "delivery_events_202612_event_timestamp_idx"
    t.index ["event_type"], name: "delivery_events_202612_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "delivery_events_202612_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "delivery_events_202612_organization_id_event_type_event_tim_idx"
    t.index ["processed_at"], name: "delivery_events_202612_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["provider"], name: "delivery_events_202612_provider_idx"
    t.index ["provider_event_id"], name: "delivery_events_202612_provider_event_id_idx", where: "(provider_event_id IS NOT NULL)"
  end

  create_table "dns_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "actual_value"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.uuid "domain_id", null: false
    t.text "expected_value"
    t.boolean "is_verified", default: false, null: false
    t.datetime "last_checked_at"
    t.string "name", null: false
    t.string "record_type", null: false
    t.string "status", default: "pending", null: false
    t.integer "ttl", default: 300
    t.datetime "updated_at", null: false
    t.text "value", null: false
    t.index ["deleted_at"], name: "index_dns_records_on_deleted_at"
    t.index ["domain_id", "record_type"], name: "index_dns_records_on_domain_id_and_record_type", where: "(deleted_at IS NULL)"
    t.index ["domain_id"], name: "index_dns_records_on_domain_id"
    t.index ["is_verified"], name: "index_dns_records_on_is_verified"
    t.index ["status"], name: "index_dns_records_on_status"
  end

  create_table "domains", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "bounce_email_prefix", default: "bounce"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.text "dkim_private_key_ciphertext"
    t.string "dkim_public_key"
    t.text "dkim_record"
    t.string "dkim_selector", default: "mailo", null: false
    t.text "dmarc_record"
    t.string "domain", null: false
    t.boolean "is_bounce_domain", default: false, null: false
    t.boolean "is_verified", default: false, null: false
    t.text "mx_record"
    t.uuid "organization_id", null: false
    t.string "region", default: "us", null: false
    t.text "spf_record"
    t.string "status", default: "pending", null: false
    t.string "tracking_subdomain", default: "track"
    t.datetime "updated_at", null: false
    t.string "verification_token", null: false
    t.datetime "verified_at"
    t.index ["deleted_at"], name: "index_domains_on_deleted_at"
    t.index ["domain"], name: "index_domains_on_domain"
    t.index ["is_verified"], name: "index_domains_on_is_verified"
    t.index ["organization_id", "domain"], name: "index_domains_on_organization_id_and_domain", unique: true, where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_domains_on_organization_id"
    t.index ["status"], name: "index_domains_on_status"
  end

  create_table "email_messages", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "index_email_messages_on_batch_id"
    t.index ["created_at"], name: "index_email_messages_on_created_at"
    t.index ["deleted_at"], name: "index_email_messages_on_deleted_at"
    t.index ["idempotency_key"], name: "index_email_messages_on_idempotency_key", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "index_email_messages_on_message_id", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "index_email_messages_on_organization_id_and_created_at"
    t.index ["organization_id", "status", "created_at"], name: "idx_on_organization_id_status_created_at_04a87d5c65"
    t.index ["organization_id"], name: "index_email_messages_on_organization_id"
    t.index ["scheduled_at"], name: "index_email_messages_on_scheduled_at", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "index_email_messages_on_status"
    t.index ["tags"], name: "index_email_messages_on_tags", using: :gin
    t.index ["to_address"], name: "index_email_messages_on_to_address"
  end

  create_table "email_messages_202401", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202401_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202401_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202401_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202401_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202401_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202401_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202401_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202401_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202401_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202401_status_idx"
    t.index ["tags"], name: "email_messages_202401_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202401_to_address_idx"
  end

  create_table "email_messages_202402", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202402_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202402_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202402_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202402_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202402_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202402_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202402_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202402_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202402_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202402_status_idx"
    t.index ["tags"], name: "email_messages_202402_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202402_to_address_idx"
  end

  create_table "email_messages_202403", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202403_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202403_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202403_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202403_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202403_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202403_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202403_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202403_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202403_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202403_status_idx"
    t.index ["tags"], name: "email_messages_202403_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202403_to_address_idx"
  end

  create_table "email_messages_202404", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202404_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202404_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202404_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202404_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202404_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202404_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202404_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202404_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202404_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202404_status_idx"
    t.index ["tags"], name: "email_messages_202404_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202404_to_address_idx"
  end

  create_table "email_messages_202405", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202405_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202405_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202405_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202405_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202405_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202405_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202405_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202405_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202405_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202405_status_idx"
    t.index ["tags"], name: "email_messages_202405_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202405_to_address_idx"
  end

  create_table "email_messages_202406", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202406_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202406_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202406_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202406_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202406_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202406_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202406_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202406_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202406_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202406_status_idx"
    t.index ["tags"], name: "email_messages_202406_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202406_to_address_idx"
  end

  create_table "email_messages_202407", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202407_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202407_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202407_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202407_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202407_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202407_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202407_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202407_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202407_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202407_status_idx"
    t.index ["tags"], name: "email_messages_202407_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202407_to_address_idx"
  end

  create_table "email_messages_202408", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202408_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202408_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202408_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202408_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202408_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202408_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202408_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202408_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202408_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202408_status_idx"
    t.index ["tags"], name: "email_messages_202408_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202408_to_address_idx"
  end

  create_table "email_messages_202409", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202409_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202409_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202409_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202409_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202409_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202409_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202409_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202409_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202409_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202409_status_idx"
    t.index ["tags"], name: "email_messages_202409_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202409_to_address_idx"
  end

  create_table "email_messages_202410", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202410_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202410_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202410_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202410_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202410_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202410_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202410_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202410_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202410_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202410_status_idx"
    t.index ["tags"], name: "email_messages_202410_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202410_to_address_idx"
  end

  create_table "email_messages_202411", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202411_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202411_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202411_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202411_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202411_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202411_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202411_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202411_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202411_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202411_status_idx"
    t.index ["tags"], name: "email_messages_202411_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202411_to_address_idx"
  end

  create_table "email_messages_202412", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202412_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202412_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202412_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202412_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202412_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202412_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202412_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202412_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202412_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202412_status_idx"
    t.index ["tags"], name: "email_messages_202412_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202412_to_address_idx"
  end

  create_table "email_messages_202501", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202501_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202501_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202501_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202501_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202501_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202501_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202501_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202501_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202501_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202501_status_idx"
    t.index ["tags"], name: "email_messages_202501_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202501_to_address_idx"
  end

  create_table "email_messages_202502", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202502_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202502_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202502_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202502_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202502_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202502_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202502_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202502_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202502_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202502_status_idx"
    t.index ["tags"], name: "email_messages_202502_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202502_to_address_idx"
  end

  create_table "email_messages_202503", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202503_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202503_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202503_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202503_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202503_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202503_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202503_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202503_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202503_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202503_status_idx"
    t.index ["tags"], name: "email_messages_202503_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202503_to_address_idx"
  end

  create_table "email_messages_202504", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202504_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202504_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202504_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202504_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202504_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202504_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202504_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202504_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202504_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202504_status_idx"
    t.index ["tags"], name: "email_messages_202504_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202504_to_address_idx"
  end

  create_table "email_messages_202505", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202505_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202505_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202505_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202505_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202505_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202505_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202505_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202505_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202505_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202505_status_idx"
    t.index ["tags"], name: "email_messages_202505_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202505_to_address_idx"
  end

  create_table "email_messages_202506", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202506_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202506_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202506_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202506_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202506_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202506_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202506_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202506_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202506_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202506_status_idx"
    t.index ["tags"], name: "email_messages_202506_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202506_to_address_idx"
  end

  create_table "email_messages_202507", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202507_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202507_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202507_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202507_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202507_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202507_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202507_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202507_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202507_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202507_status_idx"
    t.index ["tags"], name: "email_messages_202507_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202507_to_address_idx"
  end

  create_table "email_messages_202508", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202508_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202508_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202508_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202508_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202508_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202508_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202508_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202508_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202508_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202508_status_idx"
    t.index ["tags"], name: "email_messages_202508_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202508_to_address_idx"
  end

  create_table "email_messages_202509", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202509_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202509_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202509_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202509_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202509_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202509_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202509_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202509_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202509_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202509_status_idx"
    t.index ["tags"], name: "email_messages_202509_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202509_to_address_idx"
  end

  create_table "email_messages_202510", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202510_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202510_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202510_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202510_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202510_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202510_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202510_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202510_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202510_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202510_status_idx"
    t.index ["tags"], name: "email_messages_202510_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202510_to_address_idx"
  end

  create_table "email_messages_202511", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202511_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202511_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202511_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202511_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202511_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202511_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202511_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202511_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202511_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202511_status_idx"
    t.index ["tags"], name: "email_messages_202511_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202511_to_address_idx"
  end

  create_table "email_messages_202512", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202512_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202512_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202512_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202512_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202512_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202512_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202512_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202512_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202512_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202512_status_idx"
    t.index ["tags"], name: "email_messages_202512_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202512_to_address_idx"
  end

  create_table "email_messages_202601", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202601_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202601_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202601_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202601_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202601_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202601_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202601_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202601_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202601_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202601_status_idx"
    t.index ["tags"], name: "email_messages_202601_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202601_to_address_idx"
  end

  create_table "email_messages_202602", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202602_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202602_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202602_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202602_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202602_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202602_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202602_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202602_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202602_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202602_status_idx"
    t.index ["tags"], name: "email_messages_202602_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202602_to_address_idx"
  end

  create_table "email_messages_202603", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202603_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202603_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202603_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202603_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202603_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202603_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202603_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202603_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202603_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202603_status_idx"
    t.index ["tags"], name: "email_messages_202603_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202603_to_address_idx"
  end

  create_table "email_messages_202604", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202604_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202604_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202604_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202604_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202604_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202604_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202604_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202604_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202604_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202604_status_idx"
    t.index ["tags"], name: "email_messages_202604_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202604_to_address_idx"
  end

  create_table "email_messages_202605", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202605_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202605_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202605_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202605_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202605_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202605_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202605_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202605_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202605_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202605_status_idx"
    t.index ["tags"], name: "email_messages_202605_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202605_to_address_idx"
  end

  create_table "email_messages_202606", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202606_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202606_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202606_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202606_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202606_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202606_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202606_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202606_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202606_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202606_status_idx"
    t.index ["tags"], name: "email_messages_202606_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202606_to_address_idx"
  end

  create_table "email_messages_202607", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202607_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202607_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202607_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202607_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202607_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202607_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202607_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202607_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202607_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202607_status_idx"
    t.index ["tags"], name: "email_messages_202607_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202607_to_address_idx"
  end

  create_table "email_messages_202608", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202608_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202608_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202608_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202608_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202608_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202608_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202608_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202608_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202608_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202608_status_idx"
    t.index ["tags"], name: "email_messages_202608_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202608_to_address_idx"
  end

  create_table "email_messages_202609", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202609_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202609_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202609_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202609_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202609_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202609_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202609_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202609_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202609_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202609_status_idx"
    t.index ["tags"], name: "email_messages_202609_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202609_to_address_idx"
  end

  create_table "email_messages_202610", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202610_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202610_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202610_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202610_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202610_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202610_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202610_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202610_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202610_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202610_status_idx"
    t.index ["tags"], name: "email_messages_202610_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202610_to_address_idx"
  end

  create_table "email_messages_202611", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202611_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202611_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202611_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202611_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202611_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202611_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202611_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202611_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202611_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202611_status_idx"
    t.index ["tags"], name: "email_messages_202611_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202611_to_address_idx"
  end

  create_table "email_messages_202612", primary_key: ["id", "created_at"], options: "INHERITS (email_messages)", force: :cascade do |t|
    t.uuid "batch_id", null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.uuid "domain_id"
    t.timestamptz "failed_at"
    t.string "failure_code"
    t.string "failure_reason"
    t.string "from_address", null: false
    t.jsonb "headers", default: {}, null: false
    t.text "html_body"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "idempotency_key"
    t.timestamptz "last_retry_at"
    t.integer "max_retries", default: 3, null: false
    t.string "message_id"
    t.uuid "organization_id", null: false
    t.string "recipient_type", default: "to", null: false
    t.string "reply_to"
    t.integer "retry_count", default: 0, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "sent_at"
    t.string "status", default: "queued", null: false
    t.string "subject", null: false
    t.jsonb "tags", default: [], null: false
    t.uuid "template_id"
    t.text "text_body"
    t.string "to_address", null: false
    t.timestamptz "updated_at", null: false
    t.index ["batch_id"], name: "email_messages_202612_batch_id_idx"
    t.index ["created_at"], name: "email_messages_202612_created_at_idx"
    t.index ["deleted_at"], name: "email_messages_202612_deleted_at_idx"
    t.index ["idempotency_key"], name: "email_messages_202612_idempotency_key_idx", where: "(idempotency_key IS NOT NULL)"
    t.index ["message_id"], name: "email_messages_202612_message_id_idx", where: "(message_id IS NOT NULL)"
    t.index ["organization_id", "created_at"], name: "email_messages_202612_organization_id_created_at_idx"
    t.index ["organization_id", "status", "created_at"], name: "email_messages_202612_organization_id_status_created_at_idx"
    t.index ["organization_id"], name: "email_messages_202612_organization_id_idx"
    t.index ["scheduled_at"], name: "email_messages_202612_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'queued'::text))"
    t.index ["status"], name: "email_messages_202612_status_idx"
    t.index ["tags"], name: "email_messages_202612_tags_idx", using: :gin
    t.index ["to_address"], name: "email_messages_202612_to_address_idx"
  end

  create_table "email_metrics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "click_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.uuid "delivery_id"
    t.integer "delivery_latency_ms"
    t.uuid "email_message_id"
    t.datetime "first_click_at"
    t.datetime "first_open_at"
    t.boolean "is_bounced", default: false, null: false
    t.boolean "is_clicked", default: false, null: false
    t.boolean "is_complained", default: false, null: false
    t.boolean "is_delivered", default: false, null: false
    t.boolean "is_opened", default: false, null: false
    t.datetime "last_click_at"
    t.datetime "last_open_at"
    t.integer "open_count", default: 0, null: false
    t.uuid "organization_id", null: false
    t.decimal "score", precision: 5, scale: 2
    t.datetime "updated_at", null: false
    t.index ["delivery_id"], name: "index_email_metrics_on_delivery_id"
    t.index ["email_message_id"], name: "index_email_metrics_on_email_message_id", unique: true
    t.index ["is_bounced"], name: "index_email_metrics_on_is_bounced"
    t.index ["is_delivered"], name: "index_email_metrics_on_is_delivered"
    t.index ["is_opened"], name: "index_email_metrics_on_is_opened"
    t.index ["organization_id", "created_at"], name: "index_email_metrics_on_organization_id_and_created_at"
    t.index ["organization_id"], name: "index_email_metrics_on_organization_id"
  end

  create_table "event_logs", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "index_event_logs_on_created_at"
    t.index ["deleted_at"], name: "index_event_logs_on_deleted_at"
    t.index ["event_timestamp"], name: "index_event_logs_on_event_timestamp"
    t.index ["event_type"], name: "index_event_logs_on_event_type"
    t.index ["organization_id", "event_timestamp"], name: "index_event_logs_on_organization_id_and_event_timestamp"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "idx_on_organization_id_event_type_event_timestamp_22c966f9ab"
    t.index ["processed_at"], name: "index_event_logs_on_processed_at", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "index_event_logs_on_resource_type_and_resource_id"
  end

  create_table "event_logs_202401", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202401_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202401_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202401_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202401_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202401_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202401_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202401_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202401_resource_type_resource_id_idx"
  end

  create_table "event_logs_202402", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202402_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202402_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202402_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202402_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202402_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202402_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202402_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202402_resource_type_resource_id_idx"
  end

  create_table "event_logs_202403", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202403_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202403_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202403_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202403_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202403_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202403_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202403_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202403_resource_type_resource_id_idx"
  end

  create_table "event_logs_202404", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202404_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202404_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202404_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202404_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202404_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202404_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202404_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202404_resource_type_resource_id_idx"
  end

  create_table "event_logs_202405", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202405_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202405_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202405_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202405_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202405_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202405_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202405_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202405_resource_type_resource_id_idx"
  end

  create_table "event_logs_202406", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202406_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202406_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202406_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202406_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202406_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202406_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202406_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202406_resource_type_resource_id_idx"
  end

  create_table "event_logs_202407", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202407_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202407_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202407_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202407_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202407_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202407_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202407_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202407_resource_type_resource_id_idx"
  end

  create_table "event_logs_202408", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202408_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202408_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202408_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202408_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202408_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202408_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202408_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202408_resource_type_resource_id_idx"
  end

  create_table "event_logs_202409", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202409_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202409_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202409_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202409_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202409_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202409_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202409_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202409_resource_type_resource_id_idx"
  end

  create_table "event_logs_202410", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202410_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202410_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202410_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202410_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202410_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202410_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202410_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202410_resource_type_resource_id_idx"
  end

  create_table "event_logs_202411", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202411_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202411_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202411_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202411_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202411_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202411_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202411_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202411_resource_type_resource_id_idx"
  end

  create_table "event_logs_202412", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202412_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202412_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202412_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202412_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202412_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202412_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202412_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202412_resource_type_resource_id_idx"
  end

  create_table "event_logs_202501", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202501_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202501_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202501_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202501_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202501_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202501_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202501_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202501_resource_type_resource_id_idx"
  end

  create_table "event_logs_202502", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202502_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202502_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202502_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202502_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202502_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202502_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202502_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202502_resource_type_resource_id_idx"
  end

  create_table "event_logs_202503", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202503_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202503_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202503_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202503_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202503_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202503_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202503_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202503_resource_type_resource_id_idx"
  end

  create_table "event_logs_202504", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202504_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202504_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202504_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202504_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202504_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202504_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202504_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202504_resource_type_resource_id_idx"
  end

  create_table "event_logs_202505", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202505_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202505_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202505_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202505_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202505_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202505_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202505_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202505_resource_type_resource_id_idx"
  end

  create_table "event_logs_202506", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202506_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202506_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202506_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202506_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202506_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202506_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202506_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202506_resource_type_resource_id_idx"
  end

  create_table "event_logs_202507", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202507_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202507_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202507_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202507_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202507_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202507_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202507_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202507_resource_type_resource_id_idx"
  end

  create_table "event_logs_202508", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202508_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202508_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202508_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202508_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202508_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202508_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202508_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202508_resource_type_resource_id_idx"
  end

  create_table "event_logs_202509", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202509_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202509_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202509_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202509_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202509_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202509_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202509_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202509_resource_type_resource_id_idx"
  end

  create_table "event_logs_202510", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202510_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202510_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202510_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202510_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202510_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202510_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202510_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202510_resource_type_resource_id_idx"
  end

  create_table "event_logs_202511", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202511_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202511_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202511_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202511_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202511_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202511_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202511_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202511_resource_type_resource_id_idx"
  end

  create_table "event_logs_202512", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202512_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202512_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202512_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202512_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202512_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202512_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202512_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202512_resource_type_resource_id_idx"
  end

  create_table "event_logs_202601", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202601_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202601_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202601_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202601_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202601_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202601_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202601_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202601_resource_type_resource_id_idx"
  end

  create_table "event_logs_202602", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202602_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202602_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202602_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202602_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202602_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202602_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202602_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202602_resource_type_resource_id_idx"
  end

  create_table "event_logs_202603", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202603_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202603_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202603_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202603_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202603_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202603_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202603_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202603_resource_type_resource_id_idx"
  end

  create_table "event_logs_202604", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202604_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202604_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202604_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202604_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202604_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202604_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202604_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202604_resource_type_resource_id_idx"
  end

  create_table "event_logs_202605", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202605_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202605_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202605_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202605_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202605_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202605_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202605_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202605_resource_type_resource_id_idx"
  end

  create_table "event_logs_202606", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202606_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202606_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202606_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202606_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202606_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202606_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202606_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202606_resource_type_resource_id_idx"
  end

  create_table "event_logs_202607", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202607_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202607_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202607_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202607_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202607_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202607_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202607_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202607_resource_type_resource_id_idx"
  end

  create_table "event_logs_202608", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202608_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202608_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202608_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202608_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202608_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202608_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202608_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202608_resource_type_resource_id_idx"
  end

  create_table "event_logs_202609", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202609_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202609_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202609_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202609_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202609_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202609_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202609_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202609_resource_type_resource_id_idx"
  end

  create_table "event_logs_202610", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202610_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202610_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202610_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202610_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202610_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202610_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202610_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202610_resource_type_resource_id_idx"
  end

  create_table "event_logs_202611", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202611_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202611_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202611_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202611_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202611_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202611_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202611_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202611_resource_type_resource_id_idx"
  end

  create_table "event_logs_202612", primary_key: ["id", "created_at"], options: "INHERITS (event_logs)", force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "event_timestamp", null: false
    t.string "event_type", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "ip_address"
    t.jsonb "metadata", default: {}, null: false
    t.uuid "organization_id", null: false
    t.jsonb "payload", default: {}, null: false
    t.timestamptz "processed_at"
    t.uuid "resource_id"
    t.string "resource_type"
    t.string "source", null: false
    t.timestamptz "updated_at", null: false
    t.string "user_agent"
    t.index ["created_at"], name: "event_logs_202612_created_at_idx"
    t.index ["deleted_at"], name: "event_logs_202612_deleted_at_idx"
    t.index ["event_timestamp"], name: "event_logs_202612_event_timestamp_idx"
    t.index ["event_type"], name: "event_logs_202612_event_type_idx"
    t.index ["organization_id", "event_timestamp"], name: "event_logs_202612_organization_id_event_timestamp_idx"
    t.index ["organization_id", "event_type", "event_timestamp"], name: "event_logs_202612_organization_id_event_type_event_timestam_idx"
    t.index ["processed_at"], name: "event_logs_202612_processed_at_idx", where: "(processed_at IS NULL)"
    t.index ["resource_type", "resource_id"], name: "event_logs_202612_resource_type_resource_id_idx"
  end

  create_table "jobs", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "index_jobs_on_created_at"
    t.index ["deleted_at"], name: "index_jobs_on_deleted_at"
    t.index ["jid"], name: "index_jobs_on_jid", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "index_jobs_on_job_type"
    t.index ["organization_id"], name: "index_jobs_on_organization_id"
    t.index ["queue"], name: "index_jobs_on_queue"
    t.index ["resource_type", "resource_id"], name: "index_jobs_on_resource_type_and_resource_id"
    t.index ["scheduled_at"], name: "index_jobs_on_scheduled_at", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "index_jobs_on_status"
  end

  create_table "jobs_202401", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202401_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202401_deleted_at_idx"
    t.index ["jid"], name: "jobs_202401_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202401_job_type_idx"
    t.index ["organization_id"], name: "jobs_202401_organization_id_idx"
    t.index ["queue"], name: "jobs_202401_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202401_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202401_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202401_status_idx"
  end

  create_table "jobs_202402", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202402_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202402_deleted_at_idx"
    t.index ["jid"], name: "jobs_202402_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202402_job_type_idx"
    t.index ["organization_id"], name: "jobs_202402_organization_id_idx"
    t.index ["queue"], name: "jobs_202402_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202402_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202402_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202402_status_idx"
  end

  create_table "jobs_202403", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202403_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202403_deleted_at_idx"
    t.index ["jid"], name: "jobs_202403_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202403_job_type_idx"
    t.index ["organization_id"], name: "jobs_202403_organization_id_idx"
    t.index ["queue"], name: "jobs_202403_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202403_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202403_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202403_status_idx"
  end

  create_table "jobs_202404", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202404_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202404_deleted_at_idx"
    t.index ["jid"], name: "jobs_202404_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202404_job_type_idx"
    t.index ["organization_id"], name: "jobs_202404_organization_id_idx"
    t.index ["queue"], name: "jobs_202404_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202404_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202404_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202404_status_idx"
  end

  create_table "jobs_202405", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202405_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202405_deleted_at_idx"
    t.index ["jid"], name: "jobs_202405_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202405_job_type_idx"
    t.index ["organization_id"], name: "jobs_202405_organization_id_idx"
    t.index ["queue"], name: "jobs_202405_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202405_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202405_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202405_status_idx"
  end

  create_table "jobs_202406", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202406_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202406_deleted_at_idx"
    t.index ["jid"], name: "jobs_202406_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202406_job_type_idx"
    t.index ["organization_id"], name: "jobs_202406_organization_id_idx"
    t.index ["queue"], name: "jobs_202406_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202406_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202406_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202406_status_idx"
  end

  create_table "jobs_202407", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202407_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202407_deleted_at_idx"
    t.index ["jid"], name: "jobs_202407_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202407_job_type_idx"
    t.index ["organization_id"], name: "jobs_202407_organization_id_idx"
    t.index ["queue"], name: "jobs_202407_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202407_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202407_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202407_status_idx"
  end

  create_table "jobs_202408", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202408_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202408_deleted_at_idx"
    t.index ["jid"], name: "jobs_202408_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202408_job_type_idx"
    t.index ["organization_id"], name: "jobs_202408_organization_id_idx"
    t.index ["queue"], name: "jobs_202408_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202408_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202408_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202408_status_idx"
  end

  create_table "jobs_202409", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202409_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202409_deleted_at_idx"
    t.index ["jid"], name: "jobs_202409_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202409_job_type_idx"
    t.index ["organization_id"], name: "jobs_202409_organization_id_idx"
    t.index ["queue"], name: "jobs_202409_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202409_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202409_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202409_status_idx"
  end

  create_table "jobs_202410", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202410_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202410_deleted_at_idx"
    t.index ["jid"], name: "jobs_202410_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202410_job_type_idx"
    t.index ["organization_id"], name: "jobs_202410_organization_id_idx"
    t.index ["queue"], name: "jobs_202410_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202410_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202410_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202410_status_idx"
  end

  create_table "jobs_202411", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202411_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202411_deleted_at_idx"
    t.index ["jid"], name: "jobs_202411_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202411_job_type_idx"
    t.index ["organization_id"], name: "jobs_202411_organization_id_idx"
    t.index ["queue"], name: "jobs_202411_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202411_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202411_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202411_status_idx"
  end

  create_table "jobs_202412", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202412_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202412_deleted_at_idx"
    t.index ["jid"], name: "jobs_202412_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202412_job_type_idx"
    t.index ["organization_id"], name: "jobs_202412_organization_id_idx"
    t.index ["queue"], name: "jobs_202412_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202412_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202412_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202412_status_idx"
  end

  create_table "jobs_202501", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202501_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202501_deleted_at_idx"
    t.index ["jid"], name: "jobs_202501_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202501_job_type_idx"
    t.index ["organization_id"], name: "jobs_202501_organization_id_idx"
    t.index ["queue"], name: "jobs_202501_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202501_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202501_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202501_status_idx"
  end

  create_table "jobs_202502", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202502_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202502_deleted_at_idx"
    t.index ["jid"], name: "jobs_202502_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202502_job_type_idx"
    t.index ["organization_id"], name: "jobs_202502_organization_id_idx"
    t.index ["queue"], name: "jobs_202502_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202502_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202502_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202502_status_idx"
  end

  create_table "jobs_202503", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202503_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202503_deleted_at_idx"
    t.index ["jid"], name: "jobs_202503_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202503_job_type_idx"
    t.index ["organization_id"], name: "jobs_202503_organization_id_idx"
    t.index ["queue"], name: "jobs_202503_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202503_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202503_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202503_status_idx"
  end

  create_table "jobs_202504", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202504_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202504_deleted_at_idx"
    t.index ["jid"], name: "jobs_202504_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202504_job_type_idx"
    t.index ["organization_id"], name: "jobs_202504_organization_id_idx"
    t.index ["queue"], name: "jobs_202504_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202504_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202504_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202504_status_idx"
  end

  create_table "jobs_202505", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202505_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202505_deleted_at_idx"
    t.index ["jid"], name: "jobs_202505_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202505_job_type_idx"
    t.index ["organization_id"], name: "jobs_202505_organization_id_idx"
    t.index ["queue"], name: "jobs_202505_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202505_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202505_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202505_status_idx"
  end

  create_table "jobs_202506", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202506_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202506_deleted_at_idx"
    t.index ["jid"], name: "jobs_202506_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202506_job_type_idx"
    t.index ["organization_id"], name: "jobs_202506_organization_id_idx"
    t.index ["queue"], name: "jobs_202506_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202506_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202506_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202506_status_idx"
  end

  create_table "jobs_202507", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202507_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202507_deleted_at_idx"
    t.index ["jid"], name: "jobs_202507_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202507_job_type_idx"
    t.index ["organization_id"], name: "jobs_202507_organization_id_idx"
    t.index ["queue"], name: "jobs_202507_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202507_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202507_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202507_status_idx"
  end

  create_table "jobs_202508", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202508_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202508_deleted_at_idx"
    t.index ["jid"], name: "jobs_202508_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202508_job_type_idx"
    t.index ["organization_id"], name: "jobs_202508_organization_id_idx"
    t.index ["queue"], name: "jobs_202508_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202508_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202508_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202508_status_idx"
  end

  create_table "jobs_202509", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202509_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202509_deleted_at_idx"
    t.index ["jid"], name: "jobs_202509_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202509_job_type_idx"
    t.index ["organization_id"], name: "jobs_202509_organization_id_idx"
    t.index ["queue"], name: "jobs_202509_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202509_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202509_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202509_status_idx"
  end

  create_table "jobs_202510", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202510_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202510_deleted_at_idx"
    t.index ["jid"], name: "jobs_202510_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202510_job_type_idx"
    t.index ["organization_id"], name: "jobs_202510_organization_id_idx"
    t.index ["queue"], name: "jobs_202510_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202510_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202510_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202510_status_idx"
  end

  create_table "jobs_202511", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202511_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202511_deleted_at_idx"
    t.index ["jid"], name: "jobs_202511_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202511_job_type_idx"
    t.index ["organization_id"], name: "jobs_202511_organization_id_idx"
    t.index ["queue"], name: "jobs_202511_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202511_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202511_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202511_status_idx"
  end

  create_table "jobs_202512", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202512_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202512_deleted_at_idx"
    t.index ["jid"], name: "jobs_202512_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202512_job_type_idx"
    t.index ["organization_id"], name: "jobs_202512_organization_id_idx"
    t.index ["queue"], name: "jobs_202512_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202512_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202512_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202512_status_idx"
  end

  create_table "jobs_202601", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202601_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202601_deleted_at_idx"
    t.index ["jid"], name: "jobs_202601_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202601_job_type_idx"
    t.index ["organization_id"], name: "jobs_202601_organization_id_idx"
    t.index ["queue"], name: "jobs_202601_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202601_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202601_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202601_status_idx"
  end

  create_table "jobs_202602", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202602_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202602_deleted_at_idx"
    t.index ["jid"], name: "jobs_202602_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202602_job_type_idx"
    t.index ["organization_id"], name: "jobs_202602_organization_id_idx"
    t.index ["queue"], name: "jobs_202602_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202602_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202602_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202602_status_idx"
  end

  create_table "jobs_202603", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202603_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202603_deleted_at_idx"
    t.index ["jid"], name: "jobs_202603_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202603_job_type_idx"
    t.index ["organization_id"], name: "jobs_202603_organization_id_idx"
    t.index ["queue"], name: "jobs_202603_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202603_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202603_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202603_status_idx"
  end

  create_table "jobs_202604", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202604_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202604_deleted_at_idx"
    t.index ["jid"], name: "jobs_202604_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202604_job_type_idx"
    t.index ["organization_id"], name: "jobs_202604_organization_id_idx"
    t.index ["queue"], name: "jobs_202604_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202604_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202604_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202604_status_idx"
  end

  create_table "jobs_202605", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202605_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202605_deleted_at_idx"
    t.index ["jid"], name: "jobs_202605_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202605_job_type_idx"
    t.index ["organization_id"], name: "jobs_202605_organization_id_idx"
    t.index ["queue"], name: "jobs_202605_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202605_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202605_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202605_status_idx"
  end

  create_table "jobs_202606", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202606_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202606_deleted_at_idx"
    t.index ["jid"], name: "jobs_202606_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202606_job_type_idx"
    t.index ["organization_id"], name: "jobs_202606_organization_id_idx"
    t.index ["queue"], name: "jobs_202606_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202606_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202606_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202606_status_idx"
  end

  create_table "jobs_202607", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202607_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202607_deleted_at_idx"
    t.index ["jid"], name: "jobs_202607_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202607_job_type_idx"
    t.index ["organization_id"], name: "jobs_202607_organization_id_idx"
    t.index ["queue"], name: "jobs_202607_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202607_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202607_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202607_status_idx"
  end

  create_table "jobs_202608", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202608_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202608_deleted_at_idx"
    t.index ["jid"], name: "jobs_202608_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202608_job_type_idx"
    t.index ["organization_id"], name: "jobs_202608_organization_id_idx"
    t.index ["queue"], name: "jobs_202608_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202608_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202608_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202608_status_idx"
  end

  create_table "jobs_202609", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202609_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202609_deleted_at_idx"
    t.index ["jid"], name: "jobs_202609_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202609_job_type_idx"
    t.index ["organization_id"], name: "jobs_202609_organization_id_idx"
    t.index ["queue"], name: "jobs_202609_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202609_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202609_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202609_status_idx"
  end

  create_table "jobs_202610", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202610_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202610_deleted_at_idx"
    t.index ["jid"], name: "jobs_202610_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202610_job_type_idx"
    t.index ["organization_id"], name: "jobs_202610_organization_id_idx"
    t.index ["queue"], name: "jobs_202610_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202610_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202610_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202610_status_idx"
  end

  create_table "jobs_202611", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202611_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202611_deleted_at_idx"
    t.index ["jid"], name: "jobs_202611_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202611_job_type_idx"
    t.index ["organization_id"], name: "jobs_202611_organization_id_idx"
    t.index ["queue"], name: "jobs_202611_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202611_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202611_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202611_status_idx"
  end

  create_table "jobs_202612", primary_key: ["id", "created_at"], options: "INHERITS (jobs)", force: :cascade do |t|
    t.jsonb "arguments", default: {}, null: false
    t.integer "attempts", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.integer "duration_ms"
    t.timestamptz "enqueued_at"
    t.string "error_class"
    t.string "error_message"
    t.timestamptz "failed_at"
    t.timestamptz "finished_at"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.string "jid"
    t.string "job_type", null: false
    t.integer "max_attempts", default: 25, null: false
    t.uuid "organization_id"
    t.string "queue", null: false
    t.uuid "resource_id"
    t.string "resource_type"
    t.jsonb "result", default: {}, null: false
    t.timestamptz "scheduled_at"
    t.timestamptz "started_at"
    t.string "status", default: "enqueued", null: false
    t.timestamptz "updated_at", null: false
    t.string "worker_class", null: false
    t.index ["created_at"], name: "jobs_202612_created_at_idx"
    t.index ["deleted_at"], name: "jobs_202612_deleted_at_idx"
    t.index ["jid"], name: "jobs_202612_jid_idx", where: "(jid IS NOT NULL)"
    t.index ["job_type"], name: "jobs_202612_job_type_idx"
    t.index ["organization_id"], name: "jobs_202612_organization_id_idx"
    t.index ["queue"], name: "jobs_202612_queue_idx"
    t.index ["resource_type", "resource_id"], name: "jobs_202612_resource_type_resource_id_idx"
    t.index ["scheduled_at"], name: "jobs_202612_scheduled_at_idx", where: "((scheduled_at IS NOT NULL) AND ((status)::text = 'enqueued'::text))"
    t.index ["status"], name: "jobs_202612_status_idx"
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.datetime "invite_accepted_at"
    t.string "invite_email"
    t.datetime "invite_expires_at"
    t.string "invite_token"
    t.uuid "organization_id", null: false
    t.uuid "role_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["deleted_at"], name: "index_memberships_on_deleted_at"
    t.index ["invite_token"], name: "index_memberships_on_invite_token", unique: true, where: "(invite_token IS NOT NULL)"
    t.index ["organization_id", "user_id"], name: "index_memberships_on_organization_id_and_user_id", unique: true, where: "((deleted_at IS NULL) AND ((status)::text = 'active'::text))"
    t.index ["organization_id"], name: "index_memberships_on_organization_id"
    t.index ["role_id"], name: "index_memberships_on_role_id"
    t.index ["status"], name: "index_memberships_on_status"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "billing_address", limit: 500
    t.string "billing_email"
    t.string "billing_phone"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.jsonb "ip_allowlist", default: [], null: false
    t.boolean "ip_allowlist_enabled", default: false, null: false
    t.jsonb "metadata", default: {}, null: false
    t.integer "monthly_email_quota", default: 1000, null: false
    t.integer "monthly_email_sent", default: 0, null: false
    t.string "name", null: false
    t.string "plan", default: "free", null: false
    t.string "slug", null: false
    t.string "status", default: "active", null: false
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_organizations_on_created_at"
    t.index ["deleted_at"], name: "index_organizations_on_deleted_at"
    t.index ["plan"], name: "index_organizations_on_plan"
    t.index ["slug"], name: "index_organizations_on_slug", unique: true
    t.index ["status"], name: "index_organizations_on_status"
  end

  create_table "provider_attempts", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "index_provider_attempts_on_created_at"
    t.index ["deleted_at"], name: "index_provider_attempts_on_deleted_at"
    t.index ["delivery_id"], name: "index_provider_attempts_on_delivery_id"
    t.index ["organization_id", "created_at"], name: "index_provider_attempts_on_organization_id_and_created_at"
    t.index ["organization_id"], name: "index_provider_attempts_on_organization_id"
    t.index ["provider"], name: "index_provider_attempts_on_provider"
    t.index ["status"], name: "index_provider_attempts_on_status"
  end

  create_table "provider_attempts_202401", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202401_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202401_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202401_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202401_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202401_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202401_provider_idx"
    t.index ["status"], name: "provider_attempts_202401_status_idx"
  end

  create_table "provider_attempts_202402", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202402_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202402_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202402_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202402_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202402_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202402_provider_idx"
    t.index ["status"], name: "provider_attempts_202402_status_idx"
  end

  create_table "provider_attempts_202403", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202403_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202403_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202403_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202403_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202403_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202403_provider_idx"
    t.index ["status"], name: "provider_attempts_202403_status_idx"
  end

  create_table "provider_attempts_202404", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202404_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202404_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202404_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202404_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202404_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202404_provider_idx"
    t.index ["status"], name: "provider_attempts_202404_status_idx"
  end

  create_table "provider_attempts_202405", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202405_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202405_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202405_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202405_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202405_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202405_provider_idx"
    t.index ["status"], name: "provider_attempts_202405_status_idx"
  end

  create_table "provider_attempts_202406", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202406_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202406_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202406_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202406_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202406_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202406_provider_idx"
    t.index ["status"], name: "provider_attempts_202406_status_idx"
  end

  create_table "provider_attempts_202407", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202407_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202407_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202407_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202407_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202407_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202407_provider_idx"
    t.index ["status"], name: "provider_attempts_202407_status_idx"
  end

  create_table "provider_attempts_202408", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202408_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202408_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202408_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202408_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202408_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202408_provider_idx"
    t.index ["status"], name: "provider_attempts_202408_status_idx"
  end

  create_table "provider_attempts_202409", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202409_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202409_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202409_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202409_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202409_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202409_provider_idx"
    t.index ["status"], name: "provider_attempts_202409_status_idx"
  end

  create_table "provider_attempts_202410", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202410_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202410_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202410_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202410_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202410_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202410_provider_idx"
    t.index ["status"], name: "provider_attempts_202410_status_idx"
  end

  create_table "provider_attempts_202411", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202411_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202411_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202411_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202411_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202411_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202411_provider_idx"
    t.index ["status"], name: "provider_attempts_202411_status_idx"
  end

  create_table "provider_attempts_202412", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202412_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202412_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202412_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202412_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202412_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202412_provider_idx"
    t.index ["status"], name: "provider_attempts_202412_status_idx"
  end

  create_table "provider_attempts_202501", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202501_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202501_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202501_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202501_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202501_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202501_provider_idx"
    t.index ["status"], name: "provider_attempts_202501_status_idx"
  end

  create_table "provider_attempts_202502", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202502_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202502_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202502_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202502_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202502_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202502_provider_idx"
    t.index ["status"], name: "provider_attempts_202502_status_idx"
  end

  create_table "provider_attempts_202503", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202503_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202503_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202503_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202503_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202503_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202503_provider_idx"
    t.index ["status"], name: "provider_attempts_202503_status_idx"
  end

  create_table "provider_attempts_202504", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202504_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202504_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202504_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202504_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202504_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202504_provider_idx"
    t.index ["status"], name: "provider_attempts_202504_status_idx"
  end

  create_table "provider_attempts_202505", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202505_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202505_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202505_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202505_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202505_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202505_provider_idx"
    t.index ["status"], name: "provider_attempts_202505_status_idx"
  end

  create_table "provider_attempts_202506", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202506_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202506_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202506_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202506_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202506_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202506_provider_idx"
    t.index ["status"], name: "provider_attempts_202506_status_idx"
  end

  create_table "provider_attempts_202507", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202507_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202507_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202507_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202507_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202507_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202507_provider_idx"
    t.index ["status"], name: "provider_attempts_202507_status_idx"
  end

  create_table "provider_attempts_202508", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202508_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202508_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202508_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202508_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202508_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202508_provider_idx"
    t.index ["status"], name: "provider_attempts_202508_status_idx"
  end

  create_table "provider_attempts_202509", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202509_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202509_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202509_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202509_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202509_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202509_provider_idx"
    t.index ["status"], name: "provider_attempts_202509_status_idx"
  end

  create_table "provider_attempts_202510", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202510_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202510_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202510_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202510_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202510_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202510_provider_idx"
    t.index ["status"], name: "provider_attempts_202510_status_idx"
  end

  create_table "provider_attempts_202511", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202511_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202511_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202511_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202511_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202511_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202511_provider_idx"
    t.index ["status"], name: "provider_attempts_202511_status_idx"
  end

  create_table "provider_attempts_202512", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202512_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202512_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202512_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202512_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202512_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202512_provider_idx"
    t.index ["status"], name: "provider_attempts_202512_status_idx"
  end

  create_table "provider_attempts_202601", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202601_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202601_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202601_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202601_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202601_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202601_provider_idx"
    t.index ["status"], name: "provider_attempts_202601_status_idx"
  end

  create_table "provider_attempts_202602", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202602_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202602_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202602_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202602_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202602_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202602_provider_idx"
    t.index ["status"], name: "provider_attempts_202602_status_idx"
  end

  create_table "provider_attempts_202603", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202603_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202603_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202603_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202603_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202603_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202603_provider_idx"
    t.index ["status"], name: "provider_attempts_202603_status_idx"
  end

  create_table "provider_attempts_202604", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202604_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202604_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202604_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202604_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202604_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202604_provider_idx"
    t.index ["status"], name: "provider_attempts_202604_status_idx"
  end

  create_table "provider_attempts_202605", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202605_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202605_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202605_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202605_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202605_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202605_provider_idx"
    t.index ["status"], name: "provider_attempts_202605_status_idx"
  end

  create_table "provider_attempts_202606", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202606_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202606_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202606_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202606_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202606_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202606_provider_idx"
    t.index ["status"], name: "provider_attempts_202606_status_idx"
  end

  create_table "provider_attempts_202607", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202607_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202607_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202607_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202607_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202607_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202607_provider_idx"
    t.index ["status"], name: "provider_attempts_202607_status_idx"
  end

  create_table "provider_attempts_202608", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202608_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202608_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202608_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202608_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202608_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202608_provider_idx"
    t.index ["status"], name: "provider_attempts_202608_status_idx"
  end

  create_table "provider_attempts_202609", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202609_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202609_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202609_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202609_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202609_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202609_provider_idx"
    t.index ["status"], name: "provider_attempts_202609_status_idx"
  end

  create_table "provider_attempts_202610", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202610_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202610_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202610_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202610_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202610_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202610_provider_idx"
    t.index ["status"], name: "provider_attempts_202610_status_idx"
  end

  create_table "provider_attempts_202611", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202611_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202611_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202611_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202611_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202611_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202611_provider_idx"
    t.index ["status"], name: "provider_attempts_202611_status_idx"
  end

  create_table "provider_attempts_202612", primary_key: ["id", "created_at"], options: "INHERITS (provider_attempts)", force: :cascade do |t|
    t.integer "attempt_number", null: false
    t.boolean "circuit_open", default: false, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.uuid "delivery_id", null: false
    t.integer "duration_ms"
    t.string "error_class"
    t.string "error_code"
    t.string "error_message"
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.string "provider_message_id"
    t.text "request_body"
    t.text "response_body"
    t.jsonb "response_headers", default: {}, null: false
    t.boolean "retryable", default: true, null: false
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.index ["created_at"], name: "provider_attempts_202612_created_at_idx"
    t.index ["deleted_at"], name: "provider_attempts_202612_deleted_at_idx"
    t.index ["delivery_id"], name: "provider_attempts_202612_delivery_id_idx"
    t.index ["organization_id", "created_at"], name: "provider_attempts_202612_organization_id_created_at_idx"
    t.index ["organization_id"], name: "provider_attempts_202612_organization_id_idx"
    t.index ["provider"], name: "provider_attempts_202612_provider_idx"
    t.index ["status"], name: "provider_attempts_202612_status_idx"
  end

  create_table "provider_configs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "credentials", default: {}, null: false
    t.datetime "deleted_at"
    t.decimal "health_score", precision: 5, scale: 2, default: "100.0"
    t.boolean "is_active", default: true, null: false
    t.boolean "is_primary", default: false, null: false
    t.datetime "last_health_check_at"
    t.integer "max_attempts", default: 3, null: false
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "provider_type", null: false
    t.integer "rate_limit_per_hour"
    t.integer "rate_limit_per_second"
    t.string "region", default: "us"
    t.jsonb "settings", default: {}, null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.integer "weight", default: 100, null: false
    t.index ["deleted_at"], name: "index_provider_configs_on_deleted_at"
    t.index ["is_active"], name: "index_provider_configs_on_is_active"
    t.index ["organization_id", "is_primary"], name: "index_provider_configs_on_organization_id_and_is_primary", where: "((is_primary = true) AND (deleted_at IS NULL))"
    t.index ["organization_id", "provider_type"], name: "index_provider_configs_on_organization_id_and_provider_type", where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_provider_configs_on_organization_id"
    t.index ["provider_type"], name: "index_provider_configs_on_provider_type"
  end

  create_table "provider_costs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "cost_cents", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.string "currency", default: "USD"
    t.date "date", null: false
    t.integer "emails_sent", default: 0, null: false
    t.uuid "organization_id", null: false
    t.string "provider", null: false
    t.timestamptz "updated_at", null: false

    t.unique_constraint ["organization_id", "provider", "date"], name: "provider_costs_organization_id_provider_date_key"
  end

  create_table "retention_policies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.timestamptz "created_at", null: false
    t.boolean "enabled", default: true
    t.uuid "organization_id"
    t.integer "retention_days", default: 90, null: false
    t.string "table_name", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.jsonb "permissions", default: {}, null: false
    t.string "slug", null: false
    t.boolean "system", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_roles_on_slug", unique: true
  end

  create_table "rollup_1m", primary_key: ["id", "bucket"], options: "PARTITION BY RANGE (bucket)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2024_q1", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2024_q2", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2024_q3", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2024_q4", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2025_q1", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2025_q2", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2025_q3", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2025_q4", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2026_q1", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2026_q2", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2026_q3", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_1m_2026_q4", primary_key: ["id", "bucket"], options: "INHERITS (rollup_1m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m", primary_key: ["id", "bucket"], options: "PARTITION BY RANGE (bucket)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2024_q1", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2024_q2", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2024_q3", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2024_q4", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2025_q1", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2025_q2", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2025_q3", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2025_q4", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2026_q1", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2026_q2", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2026_q3", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_5m_2026_q4", primary_key: ["id", "bucket"], options: "INHERITS (rollup_5m)", force: :cascade do |t|
    t.timestamptz "bucket", null: false
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.bigint "error_count", default: 0, null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.decimal "latency_avg", precision: 10, scale: 2
    t.decimal "latency_p50", precision: 10, scale: 2
    t.decimal "latency_p90", precision: 10, scale: 2
    t.decimal "latency_p99", precision: 10, scale: 2
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
  end

  create_table "rollup_daily_domain", primary_key: ["id", "date"], options: "PARTITION BY RANGE (date)", force: :cascade do |t|
    t.integer "bounced", default: 0, null: false
    t.integer "clicked", default: 0, null: false
    t.integer "complained", default: 0, null: false
    t.date "date", null: false
    t.integer "delivered", default: 0, null: false
    t.uuid "domain_id"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.integer "opened", default: 0, null: false
    t.uuid "organization_id", null: false
    t.integer "total_sent", default: 0, null: false
  end

  create_table "rollup_daily_domain_2024", primary_key: ["id", "date"], options: "INHERITS (rollup_daily_domain)", force: :cascade do |t|
    t.integer "bounced", default: 0, null: false
    t.integer "clicked", default: 0, null: false
    t.integer "complained", default: 0, null: false
    t.date "date", null: false
    t.integer "delivered", default: 0, null: false
    t.uuid "domain_id"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.integer "opened", default: 0, null: false
    t.uuid "organization_id", null: false
    t.integer "total_sent", default: 0, null: false
  end

  create_table "rollup_daily_domain_2025", primary_key: ["id", "date"], options: "INHERITS (rollup_daily_domain)", force: :cascade do |t|
    t.integer "bounced", default: 0, null: false
    t.integer "clicked", default: 0, null: false
    t.integer "complained", default: 0, null: false
    t.date "date", null: false
    t.integer "delivered", default: 0, null: false
    t.uuid "domain_id"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.integer "opened", default: 0, null: false
    t.uuid "organization_id", null: false
    t.integer "total_sent", default: 0, null: false
  end

  create_table "rollup_daily_domain_2026", primary_key: ["id", "date"], options: "INHERITS (rollup_daily_domain)", force: :cascade do |t|
    t.integer "bounced", default: 0, null: false
    t.integer "clicked", default: 0, null: false
    t.integer "complained", default: 0, null: false
    t.date "date", null: false
    t.integer "delivered", default: 0, null: false
    t.uuid "domain_id"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.integer "opened", default: 0, null: false
    t.uuid "organization_id", null: false
    t.integer "total_sent", default: 0, null: false
  end

  create_table "team_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "role", default: "member", null: false
    t.uuid "team_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["deleted_at"], name: "index_team_memberships_on_deleted_at"
    t.index ["team_id", "user_id"], name: "index_team_memberships_on_team_id_and_user_id", unique: true, where: "(deleted_at IS NULL)"
    t.index ["team_id"], name: "index_team_memberships_on_team_id"
    t.index ["user_id"], name: "index_team_memberships_on_user_id"
  end

  create_table "teams", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "description"
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_teams_on_deleted_at"
    t.index ["organization_id", "slug"], name: "index_teams_on_organization_id_and_slug", unique: true, where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_teams_on_organization_id"
  end

  create_table "template_versions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "change_notes"
    t.datetime "created_at", null: false
    t.uuid "created_by_id"
    t.datetime "deleted_at"
    t.text "html_body"
    t.string "subject", null: false
    t.uuid "template_id", null: false
    t.text "text_body"
    t.datetime "updated_at", null: false
    t.jsonb "variables", default: [], null: false
    t.integer "version", null: false
    t.index ["created_by_id"], name: "index_template_versions_on_created_by_id"
    t.index ["deleted_at"], name: "index_template_versions_on_deleted_at"
    t.index ["template_id", "version"], name: "index_template_versions_on_template_id_and_version", unique: true, where: "(deleted_at IS NULL)"
    t.index ["template_id"], name: "index_template_versions_on_template_id"
  end

  create_table "templates", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "description"
    t.text "html_body"
    t.boolean "is_active", default: true, null: false
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.string "slug", null: false
    t.string "subject", null: false
    t.text "text_body"
    t.datetime "updated_at", null: false
    t.jsonb "variables", default: [], null: false
    t.integer "version_count", default: 1, null: false
    t.index ["deleted_at"], name: "index_templates_on_deleted_at"
    t.index ["is_active"], name: "index_templates_on_is_active"
    t.index ["organization_id", "slug"], name: "index_templates_on_organization_id_and_slug", unique: true, where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_templates_on_organization_id"
    t.index ["slug"], name: "index_templates_on_slug"
  end

  create_table "usage_records", primary_key: ["id", "bucket"], options: "PARTITION BY RANGE (bucket)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "index_usage_records_on_bucket"
    t.index ["metric"], name: "index_usage_records_on_metric"
    t.index ["organization_id", "granularity", "bucket"], name: "idx_on_organization_id_granularity_bucket_88d4632325"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "idx_usage_records_unique_bucket", unique: true
  end

  create_table "usage_records_202401", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202401_bucket_idx"
    t.index ["metric"], name: "usage_records_202401_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202401_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202401_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202404", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202404_bucket_idx"
    t.index ["metric"], name: "usage_records_202404_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202404_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202404_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202407", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202407_bucket_idx"
    t.index ["metric"], name: "usage_records_202407_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202407_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202407_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202410", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202410_bucket_idx"
    t.index ["metric"], name: "usage_records_202410_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202410_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202410_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202501", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202501_bucket_idx"
    t.index ["metric"], name: "usage_records_202501_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202501_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202501_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202502", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202502_bucket_idx"
    t.index ["metric"], name: "usage_records_202502_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202502_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202502_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202503", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202503_bucket_idx"
    t.index ["metric"], name: "usage_records_202503_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202503_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202503_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202504", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202504_bucket_idx"
    t.index ["metric"], name: "usage_records_202504_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202504_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202504_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202505", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202505_bucket_idx"
    t.index ["metric"], name: "usage_records_202505_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202505_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202505_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202506", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202506_bucket_idx"
    t.index ["metric"], name: "usage_records_202506_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202506_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202506_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202507", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202507_bucket_idx"
    t.index ["metric"], name: "usage_records_202507_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202507_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202507_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202508", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202508_bucket_idx"
    t.index ["metric"], name: "usage_records_202508_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202508_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202508_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202509", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202509_bucket_idx"
    t.index ["metric"], name: "usage_records_202509_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202509_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202509_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202510", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202510_bucket_idx"
    t.index ["metric"], name: "usage_records_202510_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202510_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202510_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202511", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202511_bucket_idx"
    t.index ["metric"], name: "usage_records_202511_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202511_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202511_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202512", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202512_bucket_idx"
    t.index ["metric"], name: "usage_records_202512_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202512_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202512_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202601", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202601_bucket_idx"
    t.index ["metric"], name: "usage_records_202601_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202601_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202601_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202602", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202602_bucket_idx"
    t.index ["metric"], name: "usage_records_202602_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202602_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202602_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202603", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202603_bucket_idx"
    t.index ["metric"], name: "usage_records_202603_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202603_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202603_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202604", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202604_bucket_idx"
    t.index ["metric"], name: "usage_records_202604_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202604_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202604_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202605", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202605_bucket_idx"
    t.index ["metric"], name: "usage_records_202605_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202605_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202605_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202606", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202606_bucket_idx"
    t.index ["metric"], name: "usage_records_202606_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202606_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202606_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202607", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202607_bucket_idx"
    t.index ["metric"], name: "usage_records_202607_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202607_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202607_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202608", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202608_bucket_idx"
    t.index ["metric"], name: "usage_records_202608_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202608_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202608_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202609", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202609_bucket_idx"
    t.index ["metric"], name: "usage_records_202609_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202609_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202609_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202610", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202610_bucket_idx"
    t.index ["metric"], name: "usage_records_202610_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202610_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202610_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202611", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202611_bucket_idx"
    t.index ["metric"], name: "usage_records_202611_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202611_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202611_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "usage_records_202612", primary_key: ["id", "bucket"], options: "INHERITS (usage_records)", force: :cascade do |t|
    t.bigint "billable_count", default: 0, null: false
    t.timestamptz "bucket", null: false
    t.decimal "cost", precision: 12, scale: 6, default: "0.0"
    t.bigint "count", default: 0, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.string "granularity", null: false
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "metric", null: false
    t.uuid "organization_id", null: false
    t.timestamptz "updated_at", null: false
    t.index ["bucket"], name: "usage_records_202612_bucket_idx"
    t.index ["metric"], name: "usage_records_202612_metric_idx"
    t.index ["organization_id", "granularity", "bucket"], name: "usage_records_202612_organization_id_granularity_bucket_idx"
    t.index ["organization_id", "metric", "granularity", "bucket"], name: "usage_records_202612_organization_id_metric_granularity_buc_idx", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.string "email", null: false
    t.integer "failed_login_attempts", default: 0, null: false
    t.string "first_name"
    t.datetime "last_login_at"
    t.string "last_login_ip"
    t.string "last_name"
    t.string "locale", default: "en", null: false
    t.datetime "locked_at"
    t.boolean "mfa_enabled", default: false, null: false
    t.text "mfa_secret_ciphertext"
    t.string "password_digest"
    t.string "status", default: "active", null: false
    t.string "timezone", default: "UTC", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "(deleted_at IS NULL)"
    t.index ["last_login_at"], name: "index_users_on_last_login_at"
    t.index ["status"], name: "index_users_on_status"
  end

  create_table "webhook_deliveries", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "index_webhook_deliveries_on_created_at"
    t.index ["deleted_at"], name: "index_webhook_deliveries_on_deleted_at"
    t.index ["event_type"], name: "index_webhook_deliveries_on_event_type"
    t.index ["organization_id", "created_at"], name: "index_webhook_deliveries_on_organization_id_and_created_at"
    t.index ["organization_id"], name: "index_webhook_deliveries_on_organization_id"
    t.index ["status"], name: "index_webhook_deliveries_on_status"
    t.index ["webhook_id", "event_id"], name: "index_webhook_deliveries_on_webhook_id_and_event_id"
    t.index ["webhook_id"], name: "index_webhook_deliveries_on_webhook_id"
  end

  create_table "webhook_deliveries_202401", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202401_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202401_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202401_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202401_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202401_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202401_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202401_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202401_webhook_id_idx"
  end

  create_table "webhook_deliveries_202402", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202402_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202402_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202402_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202402_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202402_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202402_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202402_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202402_webhook_id_idx"
  end

  create_table "webhook_deliveries_202403", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202403_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202403_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202403_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202403_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202403_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202403_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202403_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202403_webhook_id_idx"
  end

  create_table "webhook_deliveries_202404", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202404_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202404_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202404_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202404_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202404_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202404_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202404_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202404_webhook_id_idx"
  end

  create_table "webhook_deliveries_202405", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202405_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202405_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202405_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202405_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202405_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202405_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202405_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202405_webhook_id_idx"
  end

  create_table "webhook_deliveries_202406", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202406_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202406_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202406_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202406_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202406_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202406_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202406_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202406_webhook_id_idx"
  end

  create_table "webhook_deliveries_202407", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202407_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202407_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202407_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202407_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202407_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202407_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202407_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202407_webhook_id_idx"
  end

  create_table "webhook_deliveries_202408", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202408_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202408_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202408_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202408_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202408_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202408_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202408_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202408_webhook_id_idx"
  end

  create_table "webhook_deliveries_202409", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202409_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202409_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202409_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202409_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202409_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202409_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202409_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202409_webhook_id_idx"
  end

  create_table "webhook_deliveries_202410", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202410_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202410_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202410_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202410_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202410_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202410_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202410_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202410_webhook_id_idx"
  end

  create_table "webhook_deliveries_202411", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202411_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202411_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202411_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202411_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202411_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202411_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202411_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202411_webhook_id_idx"
  end

  create_table "webhook_deliveries_202412", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202412_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202412_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202412_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202412_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202412_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202412_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202412_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202412_webhook_id_idx"
  end

  create_table "webhook_deliveries_202501", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202501_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202501_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202501_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202501_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202501_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202501_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202501_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202501_webhook_id_idx"
  end

  create_table "webhook_deliveries_202502", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202502_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202502_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202502_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202502_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202502_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202502_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202502_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202502_webhook_id_idx"
  end

  create_table "webhook_deliveries_202503", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202503_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202503_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202503_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202503_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202503_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202503_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202503_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202503_webhook_id_idx"
  end

  create_table "webhook_deliveries_202504", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202504_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202504_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202504_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202504_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202504_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202504_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202504_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202504_webhook_id_idx"
  end

  create_table "webhook_deliveries_202505", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202505_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202505_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202505_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202505_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202505_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202505_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202505_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202505_webhook_id_idx"
  end

  create_table "webhook_deliveries_202506", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202506_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202506_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202506_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202506_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202506_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202506_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202506_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202506_webhook_id_idx"
  end

  create_table "webhook_deliveries_202507", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202507_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202507_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202507_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202507_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202507_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202507_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202507_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202507_webhook_id_idx"
  end

  create_table "webhook_deliveries_202508", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202508_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202508_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202508_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202508_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202508_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202508_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202508_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202508_webhook_id_idx"
  end

  create_table "webhook_deliveries_202509", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202509_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202509_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202509_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202509_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202509_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202509_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202509_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202509_webhook_id_idx"
  end

  create_table "webhook_deliveries_202510", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202510_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202510_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202510_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202510_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202510_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202510_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202510_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202510_webhook_id_idx"
  end

  create_table "webhook_deliveries_202511", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202511_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202511_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202511_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202511_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202511_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202511_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202511_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202511_webhook_id_idx"
  end

  create_table "webhook_deliveries_202512", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202512_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202512_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202512_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202512_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202512_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202512_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202512_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202512_webhook_id_idx"
  end

  create_table "webhook_deliveries_202601", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202601_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202601_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202601_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202601_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202601_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202601_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202601_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202601_webhook_id_idx"
  end

  create_table "webhook_deliveries_202602", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202602_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202602_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202602_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202602_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202602_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202602_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202602_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202602_webhook_id_idx"
  end

  create_table "webhook_deliveries_202603", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202603_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202603_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202603_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202603_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202603_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202603_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202603_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202603_webhook_id_idx"
  end

  create_table "webhook_deliveries_202604", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202604_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202604_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202604_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202604_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202604_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202604_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202604_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202604_webhook_id_idx"
  end

  create_table "webhook_deliveries_202605", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202605_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202605_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202605_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202605_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202605_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202605_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202605_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202605_webhook_id_idx"
  end

  create_table "webhook_deliveries_202606", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202606_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202606_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202606_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202606_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202606_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202606_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202606_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202606_webhook_id_idx"
  end

  create_table "webhook_deliveries_202607", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202607_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202607_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202607_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202607_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202607_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202607_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202607_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202607_webhook_id_idx"
  end

  create_table "webhook_deliveries_202608", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202608_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202608_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202608_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202608_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202608_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202608_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202608_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202608_webhook_id_idx"
  end

  create_table "webhook_deliveries_202609", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202609_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202609_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202609_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202609_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202609_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202609_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202609_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202609_webhook_id_idx"
  end

  create_table "webhook_deliveries_202610", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202610_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202610_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202610_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202610_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202610_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202610_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202610_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202610_webhook_id_idx"
  end

  create_table "webhook_deliveries_202611", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202611_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202611_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202611_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202611_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202611_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202611_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202611_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202611_webhook_id_idx"
  end

  create_table "webhook_deliveries_202612", primary_key: ["id", "created_at"], options: "INHERITS (webhook_deliveries)", force: :cascade do |t|
    t.integer "attempt", default: 1, null: false
    t.timestamptz "created_at", null: false
    t.timestamptz "deleted_at"
    t.timestamptz "delivered_at"
    t.integer "duration_ms"
    t.string "error_message"
    t.uuid "event_id", null: false
    t.string "event_type", null: false
    t.integer "http_status"
    t.uuid "id", default: -> { "gen_random_uuid()" }, null: false
    t.uuid "organization_id", null: false
    t.text "request_body"
    t.text "response_body"
    t.string "signature"
    t.string "status", default: "pending", null: false
    t.timestamptz "updated_at", null: false
    t.uuid "webhook_id", null: false
    t.index ["created_at"], name: "webhook_deliveries_202612_created_at_idx"
    t.index ["deleted_at"], name: "webhook_deliveries_202612_deleted_at_idx"
    t.index ["event_type"], name: "webhook_deliveries_202612_event_type_idx"
    t.index ["organization_id", "created_at"], name: "webhook_deliveries_202612_organization_id_created_at_idx"
    t.index ["organization_id"], name: "webhook_deliveries_202612_organization_id_idx"
    t.index ["status"], name: "webhook_deliveries_202612_status_idx"
    t.index ["webhook_id", "event_id"], name: "webhook_deliveries_202612_webhook_id_event_id_idx"
    t.index ["webhook_id"], name: "webhook_deliveries_202612_webhook_id_idx"
  end

  create_table "webhooks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "api_version", default: "v1", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
    t.jsonb "events", default: [], null: false
    t.jsonb "headers", default: {}, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "last_failure_at"
    t.datetime "last_sent_at"
    t.datetime "last_success_at"
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.integer "retry_count", default: 3, null: false
    t.string "secret", null: false
    t.text "signing_key_ciphertext"
    t.string "status", default: "active", null: false
    t.integer "timeout_ms", default: 5000, null: false
    t.datetime "updated_at", null: false
    t.string "url", null: false
    t.index ["deleted_at"], name: "index_webhooks_on_deleted_at"
    t.index ["is_active"], name: "index_webhooks_on_is_active"
    t.index ["organization_id", "url"], name: "index_webhooks_on_organization_id_and_url", unique: true, where: "(deleted_at IS NULL)"
    t.index ["organization_id"], name: "index_webhooks_on_organization_id"
    t.index ["status"], name: "index_webhooks_on_status"
  end

  add_foreign_key "api_keys", "organizations"
  add_foreign_key "api_keys", "users"
  add_foreign_key "dns_records", "domains"
  add_foreign_key "domains", "organizations"
  add_foreign_key "email_metrics", "organizations"
  add_foreign_key "memberships", "organizations"
  add_foreign_key "memberships", "roles"
  add_foreign_key "memberships", "users"
  add_foreign_key "provider_configs", "organizations"
  add_foreign_key "team_memberships", "teams"
  add_foreign_key "team_memberships", "users"
  add_foreign_key "teams", "organizations"
  add_foreign_key "template_versions", "templates"
  add_foreign_key "template_versions", "users", column: "created_by_id"
  add_foreign_key "templates", "organizations"
  add_foreign_key "webhooks", "organizations"
end
