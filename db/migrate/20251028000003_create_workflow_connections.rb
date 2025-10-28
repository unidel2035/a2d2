# frozen_string_literal: true

class CreateWorkflowConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :workflow_connections do |t|
      t.references :workflow, null: false, foreign_key: true
      t.references :source_node, null: false, foreign_key: { to_table: :workflow_nodes }
      t.references :target_node, null: false, foreign_key: { to_table: :workflow_nodes }
      t.integer :source_output_index, default: 0
      t.integer :target_input_index, default: 0
      t.string :connection_type, default: 'main'

      t.timestamps
    end

    add_index :workflow_connections, [:source_node_id, :target_node_id]
  end
end
