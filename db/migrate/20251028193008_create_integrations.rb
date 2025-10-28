class CreateIntegrations < ActiveRecord::Migration[8.0]
  def change
    create_table :integrations do |t|
      t.string :name, null: false
      t.string :integration_type, null: false # 1c, sap, bitrix24, rest_api, graphql, webhook
      t.text :description
      t.json :configuration, default: {}
      t.json :credentials, default: {} # Should be encrypted
      t.integer :status, default: 0, null: false # inactive, active, error
      t.datetime :last_sync_at
      t.text :last_error
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :integrations, :integration_type
    add_index :integrations, :status
    add_index :integrations, :name
  end
end
