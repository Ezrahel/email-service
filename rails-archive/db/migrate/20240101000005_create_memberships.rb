class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :role, null: false, foreign_key: true, type: :uuid
      t.string :invite_email
      t.string :invite_token
      t.datetime :invite_accepted_at
      t.datetime :invite_expires_at
      t.string :status, null: false, default: "active"
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :memberships, %i[organization_id user_id], unique: true, where: "deleted_at IS NULL AND status = 'active'"
    add_index :memberships, :invite_token, unique: true, where: "invite_token IS NOT NULL"
    add_index :memberships, :status
    add_index :memberships, :deleted_at
  end
end
