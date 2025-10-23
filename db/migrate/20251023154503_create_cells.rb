class CreateCells < ActiveRecord::Migration[8.1]
  def change
    create_table :cells do |t|
      t.references :row, null: false, foreign_key: true
      t.string :column_key, null: false
      t.text :value
      t.text :formula
      t.string :data_type, default: 'text'
      t.json :metadata, default: {}

      t.timestamps

      t.index [:row_id, :column_key], unique: true
    end
  end
end
