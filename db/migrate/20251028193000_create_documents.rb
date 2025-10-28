class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title, null: false
      t.text :description
      t.integer :category, default: 0, null: false
      t.string :version
      t.date :issue_date
      t.date :expiry_date
      t.text :content_text # For full-text search
      t.json :metadata, default: {}
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.string :classification # Auto-classified by Analyzer Agent
      t.json :extracted_data # Data extracted by Transformer Agent
      t.integer :parent_id # For versioning
      t.integer :version_number, default: 1

      t.timestamps
    end

    add_index :documents, :category
    add_index :documents, :status
    add_index :documents, :classification
    add_index :documents, :parent_id
    add_index :documents, :created_at
  end
end
