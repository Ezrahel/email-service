class CreateApiKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :api_keys, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :user, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :key_prefix, null: false
      t.string :key_digest, null: false
      t.string :key_last_chars, null: false
      t.jsonb :scopes, null: false, default: []
      t.jsonb :allowed_ips, null: false, default: []
      t.string :status, null: false, default: "active"
      t.datetime :expires_at
      t.datetime :last_used_at
      t.datetime :revoked_at
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :api_keys, :key_digest, unique: true
    add_index :api_keys, :key_prefix
    add_index :api_keys, %i[organization_id status]
    add_index :api_keys, :status
    add_index :api_keys, :deleted_at
  end
end
