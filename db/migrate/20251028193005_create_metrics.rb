class CreateMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :metrics do |t|
      t.string :name, null: false
      t.string :metric_type, null: false # counter, gauge, histogram
      t.decimal :value, precision: 20, scale: 6
      t.json :labels, default: {}
      t.json :metadata, default: {}
      t.datetime :recorded_at, null: false

      t.timestamps
    end

    add_index :metrics, :name
    add_index :metrics, :metric_type
    add_index :metrics, :recorded_at
    add_index :metrics, [:name, :recorded_at]
  end
end
