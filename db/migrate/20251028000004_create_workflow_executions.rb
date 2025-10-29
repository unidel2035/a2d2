# frozen_string_literal: true

class CreateWorkflowExecutions < ActiveRecord::Migration[8.1]
  def change
    create_table :workflow_executions do |t|
      t.references :workflow, null: false, foreign_key: true
      t.string :status, null: false, default: 'new'
      t.string :mode # manual, trigger, webhook, etc.
      t.datetime :started_at
      t.datetime :stopped_at
      t.datetime :finished_at
      t.text :data # JSON - input/output data
      t.text :error_message

      t.timestamps
    end

    add_index :workflow_executions, :status
    add_index :workflow_executions, :started_at
    add_index :workflow_executions, [:workflow_id, :status]
  end
end
