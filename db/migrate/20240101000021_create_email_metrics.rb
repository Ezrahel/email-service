class CreateEmailMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :email_metrics, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :email_message, foreign_key: true, type: :uuid
      t.references :delivery, foreign_key: true, type: :uuid
      t.boolean :is_delivered, null: false, default: false
      t.boolean :is_opened, null: false, default: false
      t.boolean :is_clicked, null: false, default: false
      t.boolean :is_bounced, null: false, default: false
      t.boolean :is_complained, null: false, default: false
      t.datetime :first_open_at
      t.datetime :last_open_at
      t.integer :open_count, null: false, default: 0
      t.datetime :first_click_at
      t.datetime :last_click_at
      t.integer :click_count, null: false, default: 0
      t.integer :delivery_latency_ms
      t.decimal :score, precision: 5, scale: 2
      t.timestamps
    end

    add_index :email_metrics, :organization_id
    add_index :email_metrics, :email_message_id, unique: true
    add_index :email_metrics, :is_delivered
    add_index :email_metrics, :is_opened
    add_index :email_metrics, :is_bounced
    add_index :email_metrics, %i[organization_id created_at]
  end
end
