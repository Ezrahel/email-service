class CreateAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :attachments, id: :uuid do |t|
      t.references :email_message, null: false, foreign_key: true, type: :uuid
      t.string :filename, null: false
      t.string :content_type, null: false
      t.integer :byte_size, null: false
      t.string :s3_key, null: false
      t.string :s3_bucket, null: false
      t.string :content_id
      t.boolean :is_inline, null: false, default: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :attachments, :email_message_id
    add_index :attachments, :s3_key, unique: true
    add_index :attachments, :deleted_at
  end
end
