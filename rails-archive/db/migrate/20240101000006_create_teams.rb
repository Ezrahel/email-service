class CreateTeams < ActiveRecord::Migration[8.0]
  def change
    create_table :teams, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :slug, null: false
      t.string :description
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :teams, %i[organization_id slug], unique: true, where: "deleted_at IS NULL"
    add_index :teams, :deleted_at
  end
end
