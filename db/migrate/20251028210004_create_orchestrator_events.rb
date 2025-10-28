class CreateOrchestratorEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :orchestrator_events do |t|
      t.string :event_type, null: false # task_assigned, agent_heartbeat, task_completed, verification_failed, etc.
      t.references :agent, foreign_key: true
      t.references :agent_task, foreign_key: true
      t.string :severity # info, warning, error, critical
      t.text :event_data # JSON object with event details
      t.text :message
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :orchestrator_events, :event_type
    add_index :orchestrator_events, :severity
    add_index :orchestrator_events, :occurred_at
  end
end
