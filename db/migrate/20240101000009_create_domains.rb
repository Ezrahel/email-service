class CreateDomains < ActiveRecord::Migration[8.0]
  def change
    create_table :domains, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :domain, null: false
      t.string :status, null: false, default: "pending"
      t.string :region, null: false, default: "us"
      t.boolean :is_verified, null: false, default: false
      t.datetime :verified_at
      t.string :verification_token, null: false
      t.string :dkim_selector, null: false, default: "mailo"
      t.string :dkim_private_key, encrypted: true
      t.string :dkim_public_key
      t.text :spf_record
      t.text :dkim_record
      t.text :dmarc_record
      t.text :mx_record
      t.string :tracking_subdomain, default: "track"
      t.boolean :is_bounce_domain, null: false, default: false
      t.string :bounce_email_prefix, default: "bounce"
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :domains, %i[organization_id domain], unique: true, where: "deleted_at IS NULL"
    add_index :domains, :domain
    add_index :domains, :status
    add_index :domains, :is_verified
    add_index :domains, :deleted_at
  end
end
