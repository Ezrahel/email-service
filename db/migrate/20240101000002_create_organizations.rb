class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :plan, null: false, default: "free"
      t.string :billing_email
      t.string :billing_phone
      t.string :billing_address, limit: 500
      t.boolean :ip_allowlist_enabled, null: false, default: false
      t.jsonb :ip_allowlist, null: false, default: []
      t.jsonb :metadata, null: false, default: {}
      t.integer :monthly_email_quota, null: false, default: 1000
      t.integer :monthly_email_sent, null: false, default: 0
      t.string :status, null: false, default: "active"
      t.datetime :trial_ends_at
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :organizations, :slug, unique: true
    add_index :organizations, :status
    add_index :organizations, :deleted_at
    add_index :organizations, :plan
    add_index :organizations, :created_at
  end
end
