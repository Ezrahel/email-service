class CreateTeamMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :team_memberships, id: :uuid do |t|
      t.references :team, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :role, null: false, default: "member"
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :team_memberships, %i[team_id user_id], unique: true, where: "deleted_at IS NULL"
    add_index :team_memberships, :deleted_at
  end
end
