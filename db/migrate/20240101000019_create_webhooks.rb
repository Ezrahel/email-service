class CreateWebhooks < ActiveRecord::Migration[8.0]
  def change
    create_table :webhooks, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :url, null: false
      t.jsonb :events, null: false, default: []
      t.string :secret, null: false
      t.string :status, null: false, default: "active"
      t.jsonb :headers, null: false, default: {}
      t.string :signing_key, encrypted: true
      t.string :api_version, null: false, default: "v1"
      t.boolean :is_active, null: false, default: true
      t.integer :retry_count, null: false, default: 3
      t.integer :timeout_ms, null: false, default: 5000
      t.datetime :last_sent_at
      t.datetime :last_success_at
      t.datetime :last_failure_at
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :webhooks, %i[organization_id url], unique: true, where: "deleted_at IS NULL"
    add_index :webhooks, :status
    add_index :webhooks, :is_active
    add_index :webhooks, :deleted_at
  end
end
