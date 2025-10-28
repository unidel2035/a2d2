class CreateAgentCollaborations < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_collaborations do |t|
      t.references :agent_task, null: false, foreign_key: true
      t.references :primary_agent, null: false, foreign_key: { to_table: :agents }
      t.string :collaboration_type # review, consensus, assistance
      t.string :status, default: "pending" # pending, in_progress, completed, failed
      t.text :participating_agent_ids # JSON array
      t.text :consensus_results # JSON object with voting/consensus data
      t.text :collaboration_metadata # JSON object with additional data
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :agent_collaborations, :collaboration_type
    add_index :agent_collaborations, :status
  end
end
