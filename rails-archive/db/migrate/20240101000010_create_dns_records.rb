class CreateDnsRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :dns_records, id: :uuid do |t|
      t.references :domain, null: false, foreign_key: true, type: :uuid
      t.string :record_type, null: false
      t.string :name, null: false
      t.text :value, null: false
      t.integer :ttl, default: 300
      t.string :status, null: false, default: "pending"
      t.boolean :is_verified, null: false, default: false
      t.datetime :last_checked_at
      t.text :expected_value
      t.text :actual_value
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :dns_records, %i[domain_id record_type], where: "deleted_at IS NULL"
    add_index :dns_records, :status
    add_index :dns_records, :is_verified
    add_index :dns_records, :deleted_at
  end
end
