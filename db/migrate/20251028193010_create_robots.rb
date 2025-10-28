class CreateRobots < ActiveRecord::Migration[8.0]
  def change
    create_table :robots do |t|
      t.string :manufacturer
      t.string :model
      t.string :serial_number
      t.string :registration_number
      t.json :specifications, default: {}
      t.json :capabilities, default: {}
      t.json :configuration, default: {}
      t.integer :status, default: 0, null: false # active, maintenance, repair, retired
      t.date :purchase_date
      t.date :last_maintenance_date
      t.decimal :total_operation_hours, precision: 10, scale: 2, default: 0
      t.integer :total_tasks, default: 0

      t.timestamps
    end

    add_index :robots, :status
    add_index :robots, :serial_number, unique: true
    add_index :robots, :registration_number
  end
end
