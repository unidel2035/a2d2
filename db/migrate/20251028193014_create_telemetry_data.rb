class CreateTelemetryData < ActiveRecord::Migration[8.0]
  def change
    create_table :telemetry_data do |t|
      t.references :robot, null: false, foreign_key: true
      t.references :task, foreign_key: true
      t.datetime :recorded_at, null: false
      t.json :data, default: {}
      t.string :location
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.decimal :altitude, precision: 10, scale: 2
      t.json :sensors, default: {}

      t.timestamps
    end

    add_index :telemetry_data, [:robot_id, :recorded_at]
    add_index :telemetry_data, :recorded_at
  end
end
