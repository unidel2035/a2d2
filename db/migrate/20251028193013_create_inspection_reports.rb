class CreateInspectionReports < ActiveRecord::Migration[8.0]
  def change
    create_table :inspection_reports do |t|
      t.string :report_number, null: false
      t.date :inspection_date
      t.string :location
      t.string :coordinates # lat,lng
      t.string :object_type
      t.text :findings
      t.text :recommendations
      t.integer :status, default: 0, null: false # draft, completed, approved
      t.references :task, null: false, foreign_key: true
      t.json :metadata, default: {}

      t.timestamps
    end

    add_index :inspection_reports, :report_number, unique: true
    add_index :inspection_reports, :status
    add_index :inspection_reports, :inspection_date
  end
end
