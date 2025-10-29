class CreateProcessStepExecutions < ActiveRecord::Migration[8.0]
  def change
    create_table :process_step_executions do |t|
      t.references :process_execution, null: false, foreign_key: true
      t.references :process_step, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :status, default: 0, null: false # pending, running, completed, failed, skipped
      t.json :input_data, default: {}
      t.json :output_data, default: {}
      t.text :error_message
      t.integer :retry_count, default: 0

      t.timestamps
    end

    add_index :process_step_executions, :status
    add_index :process_step_executions, [:process_execution_id, :created_at]
  end
end
