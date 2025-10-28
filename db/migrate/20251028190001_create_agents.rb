class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.string :agent_type, null: false
      t.string :status, default: 'inactive', null: false
      t.json :capabilities, default: []
      t.string :version
      t.string :endpoint
      t.json :metadata, default: {}
      t.datetime :last_heartbeat
      t.integer :priority, default: 0
      t.float :health_score, default: 100.0

      t.timestamps
    end

    add_index :agents, :name, unique: true
    add_index :agents, :agent_type
    add_index :agents, :status
    add_index :agents, :last_heartbeat
  end
end
