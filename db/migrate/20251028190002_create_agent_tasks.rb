class CreateAgentTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_tasks do |t|
      t.string :task_type, null: false
      t.string :status, default: 'pending', null: false  # pending, assigned, running, completed, failed, dead_letter
      t.integer :priority, default: 5, null: false

      # Phase 3: data fields
      t.text :payload
      t.text :result

      # Main branch: data fields
      t.text :input_data
      t.text :output_data

      # Common fields
      t.text :metadata
      t.text :error_message

      # Agent association
      t.references :agent, foreign_key: true

      # Phase 3: task hierarchy
      t.integer :parent_task_id

      # Main branch: additional fields
      t.text :dependencies
      t.text :verification_details
      t.text :execution_context
      t.text :reviewed_by_agent_ids
      t.string :verification_status  # pending, passed, failed
      t.float :quality_score

      # Timing fields
      t.datetime :deadline
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :completed_at

      # Retry logic
      t.integer :retry_count, default: 0
      t.integer :max_retries, default: 3

      # Capability requirements
      t.string :required_capability

      t.timestamps
    end

    add_index :agent_tasks, :status
    add_index :agent_tasks, :priority
    add_index :agent_tasks, :task_type
    add_index :agent_tasks, :parent_task_id
    add_index :agent_tasks, :deadline
    add_index :agent_tasks, [:status, :priority]
    add_index :agent_tasks, :verification_status
    add_foreign_key :agent_tasks, :agent_tasks, column: :parent_task_id
  end
end
