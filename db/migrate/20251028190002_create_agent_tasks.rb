class CreateAgentTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_tasks do |t|
      t.references :agent, foreign_key: true
      t.string :task_type, null: false
      t.string :status, default: "pending" # pending, processing, completed, failed
      t.integer :priority, default: 5
      t.text :input_data
      t.text :output_data
      t.text :metadata
      t.text :error_message
      t.datetime :scheduled_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :deadline_at

      t.timestamps
    end

    add_index :agent_tasks, :status
    add_index :agent_tasks, :priority
    add_index :agent_tasks, :scheduled_at
    add_index :agent_tasks, :deadline_at
  end
end
