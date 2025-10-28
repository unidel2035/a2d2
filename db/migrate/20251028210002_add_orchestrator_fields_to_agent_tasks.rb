class AddOrchestratorFieldsToAgentTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :agent_tasks, :retry_count, :integer, default: 0
    add_column :agent_tasks, :max_retries, :integer, default: 3
    add_column :agent_tasks, :dependencies, :text # JSON array of dependent task IDs
    add_column :agent_tasks, :verification_status, :string # pending, passed, failed
    add_column :agent_tasks, :verification_details, :text # JSON object with verification results
    add_column :agent_tasks, :assigned_strategy, :string # round_robin, least_loaded, capability_match
    add_column :agent_tasks, :execution_context, :text # JSON object with execution environment info
    add_column :agent_tasks, :quality_score, :decimal, precision: 5, scale: 2
    add_column :agent_tasks, :reviewed_by_agent_ids, :text # JSON array of agent IDs that reviewed this task

    add_index :agent_tasks, :retry_count
    add_index :agent_tasks, :verification_status
    add_index :agent_tasks, :quality_score
  end
end
