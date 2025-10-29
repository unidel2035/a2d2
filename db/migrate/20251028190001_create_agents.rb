class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.string :agent_type, null: false  # Phase 3: agent type field
      t.string :type  # Main branch: STI for different agent types
      t.string :status, default: 'idle', null: false  # idle, busy, inactive, failed, offline
      t.text :description  # Main branch: agent description
      t.text :capabilities  # Both: agent capabilities (JSON serialized)
      t.text :configuration  # Main branch: agent configuration
      t.text :specialization_tags  # Main branch: specialization tags
      t.text :performance_metrics  # Main branch: performance metrics
      t.string :version
      t.string :endpoint
      t.text :metadata
      t.datetime :last_heartbeat  # Phase 3: last heartbeat
      t.datetime :last_heartbeat_at  # Main branch: last heartbeat
      t.integer :priority, default: 0
      t.float :health_score, default: 100.0

      # Main branch: task tracking columns
      t.integer :current_task_count, default: 0
      t.integer :max_concurrent_tasks, default: 5
      t.integer :total_tasks_completed, default: 0
      t.integer :total_tasks_failed, default: 0
      t.float :success_rate, default: 0.0
      t.integer :average_completion_time, default: 0
      t.integer :load_score, default: 0

      t.timestamps
    end

    add_index :agents, :name, unique: true
    add_index :agents, :agent_type
    add_index :agents, :status
    add_index :agents, :last_heartbeat
  end
end
