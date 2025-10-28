class CreateAgents < ActiveRecord::Migration[8.1]
  def change
    create_table :agents do |t|
      t.string :name, null: false
      t.string :type, null: false # STI for different agent types
      t.string :status, default: "idle" # idle, busy, error, offline
      t.text :description
      t.jsonb :capabilities, default: {}
      t.jsonb :configuration, default: {}
      t.datetime :last_heartbeat_at
      t.string :version

      t.timestamps
    end

    add_index :agents, :type
    add_index :agents, :status
    add_index :agents, :last_heartbeat_at
  end
end
