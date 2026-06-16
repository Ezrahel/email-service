class CreateTemplateVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :template_versions, id: :uuid do |t|
      t.references :template, null: false, foreign_key: true, type: :uuid
      t.integer :version, null: false
      t.string :subject, null: false
      t.text :html_body
      t.text :text_body
      t.jsonb :variables, null: false, default: []
      t.string :change_notes
      t.references :created_by, foreign_key: { to_table: :users }, type: :uuid
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :template_versions, %i[template_id version], unique: true, where: "deleted_at IS NULL"
    add_index :template_versions, :deleted_at
  end
end
