class CreateTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :templates, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :slug, null: false
      t.string :description
      t.string :subject, null: false
      t.text :html_body
      t.text :text_body
      t.jsonb :variables, null: false, default: []
      t.boolean :is_active, null: false, default: true
      t.integer :version_count, null: false, default: 1
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :templates, %i[organization_id slug], unique: true, where: "deleted_at IS NULL"
    add_index :templates, :slug
    add_index :templates, :is_active
    add_index :templates, :deleted_at
  end
end
