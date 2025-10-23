class CreateRows < ActiveRecord::Migration[8.1]
  def change
    create_table :rows do |t|
      t.references :sheet, null: false, foreign_key: true
      t.integer :position, null: false
      t.json :data, default: {}

      t.timestamps

      t.index [:sheet_id, :position]
    end
  end
end
