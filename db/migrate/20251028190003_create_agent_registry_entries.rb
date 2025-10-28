class CreateAgentRegistryEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :agent_registry_entries do |t|
      t.references :agent, null: false, foreign_key: true
      t.string :registration_status, default: 'registered', null: false
      t.datetime :registered_at, null: false
      t.datetime :last_health_check
      t.integer :consecutive_failures, default: 0
      t.json :health_check_data, default: {}
      t.json :performance_metrics, default: {}
      t.boolean :active, default: true

      t.timestamps
    end

    add_index :agent_registry_entries, :registration_status
    add_index :agent_registry_entries, :active
    add_index :agent_registry_entries, :last_health_check
  end
end
