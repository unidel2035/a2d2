class CreateProcesses < ActiveRecord::Migration[8.0]
  def change
    create_table :processes do |t|
      t.string :name, null: false
      t.text :description
      t.json :definition, default: {} # JSON-based process definition
      t.integer :version_number, default: 1
      t.integer :parent_id # For versioning
      t.integer :status, default: 0, null: false # draft, active, inactive
      t.references :user, null: false, foreign_key: true
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :processes, :status
    add_index :processes, :parent_id
    add_index :processes, :name
  end
end
