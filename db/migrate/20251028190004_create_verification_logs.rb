class CreateVerificationLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :verification_logs do |t|
      t.references :agent_task, null: false, foreign_key: true
      t.references :agent, foreign_key: true
      t.string :verification_type, null: false
      t.string :status, null: false
      t.float :quality_score
      t.json :verification_data, default: {}
      t.json :issues_found, default: []
      t.text :notes
      t.boolean :auto_reassigned, default: false
      t.integer :reassigned_to_task_id

      t.timestamps
    end

    add_index :verification_logs, :verification_type
    add_index :verification_logs, :status
    add_index :verification_logs, :quality_score
    add_index :verification_logs, :auto_reassigned
    add_foreign_key :verification_logs, :agent_tasks, column: :reassigned_to_task_id
  end
end
