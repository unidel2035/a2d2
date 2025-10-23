class CreateSheets < ActiveRecord::Migration[8.1]
  def change
    create_table :sheets do |t|
      t.references :spreadsheet, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, default: 0
      t.json :column_definitions, default: []
      t.json :settings, default: {}

      t.timestamps

      t.index [:spreadsheet_id, :position]
    end
  end
end
