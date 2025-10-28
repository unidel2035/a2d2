class CreateProcessExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :process_executions do |t|
      t.references :process, null: false, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :status, default: 0, null: false # pending, running, completed, failed, cancelled
      t.json :input_data, default: {}
      t.json :output_data, default: {}
      t.json :context, default: {}
      t.text :error_message
      t.integer :current_step_id

      t.timestamps
    end

    add_index :process_executions, :status
    add_index :process_executions, :started_at
    add_index :process_executions, :completed_at
  end
end
