class CreateMaintenanceRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :maintenance_records do |t|
      t.references :robot, null: false, foreign_key: true
      t.references :technician, foreign_key: { to_table: :users }
      t.date :scheduled_date
      t.date :completed_date
      t.integer :maintenance_type, default: 0, null: false # routine, repair, component_replacement
      t.text :description
      t.decimal :cost, precision: 10, scale: 2
      t.date :next_maintenance_date
      t.decimal :operation_hours_at_maintenance, precision: 10, scale: 2
      t.json :replaced_components, default: []
      t.integer :status, default: 0, null: false # scheduled, in_progress, completed, cancelled

      t.timestamps
    end

    add_index :maintenance_records, :scheduled_date
    add_index :maintenance_records, :status
    add_index :maintenance_records, :maintenance_type
  end
end
