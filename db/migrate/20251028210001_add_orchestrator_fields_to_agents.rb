class AddOrchestratorFieldsToAgents < ActiveRecord::Migration[8.1]
  def change
    add_column :agents, :load_score, :integer, default: 0
    add_column :agents, :success_rate, :decimal, precision: 5, scale: 2, default: 100.0
    add_column :agents, :total_tasks_completed, :integer, default: 0
    add_column :agents, :total_tasks_failed, :integer, default: 0
    add_column :agents, :average_completion_time, :integer, default: 0 # in seconds
    add_column :agents, :specialization_tags, :text # JSON array of specializations
    add_column :agents, :performance_metrics, :text # JSON object for detailed metrics
    add_column :agents, :heartbeat_interval, :integer, default: 300 # in seconds
    add_column :agents, :max_concurrent_tasks, :integer, default: 5
    add_column :agents, :current_task_count, :integer, default: 0

    add_index :agents, :load_score
    add_index :agents, :success_rate
  end
end
