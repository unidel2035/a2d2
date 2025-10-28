class CreateIntegrationLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :integration_logs do |t|
      t.references :integration, null: false, foreign_key: true
      t.string :operation, null: false # sync, send, receive, transform
      t.integer :status, default: 0, null: false # success, failed, pending
      t.json :request_data, default: {}
      t.json :response_data, default: {}
      t.text :error_message
      t.float :duration # in seconds
      t.datetime :executed_at, null: false

      t.timestamps
    end

    add_index :integration_logs, [:integration_id, :executed_at]
    add_index :integration_logs, :status
    add_index :integration_logs, :operation
  end
end
