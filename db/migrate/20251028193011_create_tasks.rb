class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :task_number, null: false
      t.datetime :planned_date
      t.datetime :actual_start
      t.datetime :actual_end
      t.integer :duration # in minutes
      t.string :purpose
      t.string :location
      t.json :parameters, default: {}
      t.text :context_data
      t.integer :status, default: 0, null: false # planned, in_progress, completed, cancelled
      t.references :robot, null: false, foreign_key: true
      t.references :operator, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :tasks, :task_number, unique: true
    add_index :tasks, :status
    add_index :tasks, :planned_date
  end
end
