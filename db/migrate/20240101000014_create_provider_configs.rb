class CreateProviderConfigs < ActiveRecord::Migration[8.0]
  def change
    create_table :provider_configs, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :provider_type, null: false
      t.jsonb :credentials, null: false, default: {}
      t.jsonb :settings, null: false, default: {}
      t.integer :weight, null: false, default: 100
      t.integer :priority, null: false, default: 0
      t.string :region, default: "us"
      t.decimal :health_score, precision: 5, scale: 2, default: 100.0
      t.boolean :is_active, null: false, default: true
      t.boolean :is_primary, null: false, default: false
      t.integer :rate_limit_per_second
      t.integer :rate_limit_per_hour
      t.integer :max_attempts, null: false, default: 3
      t.string :status, null: false, default: "active"
      t.datetime :last_health_check_at
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :provider_configs, %i[organization_id provider_type], where: "deleted_at IS NULL"
    add_index :provider_configs, %i[organization_id is_primary], where: "is_primary = true AND deleted_at IS NULL"
    add_index :provider_configs, :provider_type
    add_index :provider_configs, :is_active
    add_index :provider_configs, :deleted_at
  end
end
