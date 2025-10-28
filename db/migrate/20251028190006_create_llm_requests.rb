class CreateLlmRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_requests do |t|
      t.references :agent_task, foreign_key: true
      t.string :provider, null: false # openai, anthropic, deepseek, etc.
      t.string :model, null: false
      t.integer :prompt_tokens
      t.integer :completion_tokens
      t.integer :total_tokens
      t.decimal :cost, precision: 10, scale: 6
      t.integer :response_time_ms
      t.string :status # success, error, rate_limited
      t.text :error_message
      t.jsonb :request_data
      t.jsonb :response_data

      t.timestamps
    end

    add_index :llm_requests, :provider
    add_index :llm_requests, :model
    add_index :llm_requests, :status
    add_index :llm_requests, :created_at
  end
end
