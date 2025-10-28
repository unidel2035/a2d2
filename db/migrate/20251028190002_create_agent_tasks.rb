class CreateAgentTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_tasks do |t|
      t.string :task_type, null: false
      t.string :status, default: 'pending', null: false
      t.integer :priority, default: 0, null: false
      t.json :payload, default: {}
      t.json :result, default: {}
      t.json :metadata, default: {}
      t.references :agent, foreign_key: true
      t.integer :parent_task_id
      t.datetime :deadline
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :retry_count, default: 0
      t.integer :max_retries, default: 3
      t.text :error_message
      t.string :required_capability

      t.timestamps
    end

    add_index :agent_tasks, :status
    add_index :agent_tasks, :priority
    add_index :agent_tasks, :task_type
    add_index :agent_tasks, :parent_task_id
    add_index :agent_tasks, :deadline
    add_index :agent_tasks, [:status, :priority]
    add_foreign_key :agent_tasks, :agent_tasks, column: :parent_task_id
  end
end
