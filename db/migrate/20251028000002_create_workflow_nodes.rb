# frozen_string_literal: true

class CreateWorkflowNodes < ActiveRecord::Migration[8.1]
  def change
    create_table :workflow_nodes do |t|
      t.references :workflow, null: false, foreign_key: true
      t.string :name, null: false
      t.string :node_type, null: false
      t.integer :type_version, default: 1
      t.text :position # JSON array [x, y]
      t.text :parameters # JSON object
      t.text :credentials # JSON object

      t.timestamps
    end

    add_index :workflow_nodes, :node_type
    add_index :workflow_nodes, [:workflow_id, :name]
  end
end
