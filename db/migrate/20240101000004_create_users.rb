class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.string :avatar_url
      t.string :timezone, null: false, default: "UTC"
      t.string :locale, null: false, default: "en"
      t.string :status, null: false, default: "active"
      t.boolean :mfa_enabled, null: false, default: false
      t.string :mfa_secret, encrypted: true
      t.integer :failed_login_attempts, null: false, default: 0
      t.datetime :locked_at
      t.datetime :last_login_at
      t.string :last_login_ip
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :users, :email, unique: true, where: "deleted_at IS NULL"
    add_index :users, :status
    add_index :users, :deleted_at
    add_index :users, :last_login_at
    add_index :users, :created_at
  end
end
