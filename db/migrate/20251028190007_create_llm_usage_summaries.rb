class CreateLlmUsageSummaries < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_usage_summaries, if_not_exists: true do |t|
      t.string :provider, null: false
      t.string :model, null: false
      t.date :date, null: false
      t.integer :request_count, default: 0
      t.bigint :total_tokens, default: 0
      t.bigint :prompt_tokens, default: 0
      t.bigint :completion_tokens, default: 0
      t.decimal :total_cost, precision: 12, scale: 6, default: 0
      t.integer :error_count, default: 0
      t.integer :avg_response_time_ms

      t.timestamps
    end

    add_index :llm_usage_summaries, [ :provider, :model, :date ], unique: true, name: "index_llm_usage_on_provider_model_date", if_not_exists: true
    add_index :llm_usage_summaries, :date, if_not_exists: true
  end
end
