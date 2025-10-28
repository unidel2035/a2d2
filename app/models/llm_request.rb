class LlmRequest < ApplicationRecord
  belongs_to :agent_task, optional: true

  # Validations
  validates :provider, presence: true
  validates :model, presence: true

  # Scopes
  scope :by_provider, ->(provider) { where(provider: provider) }
  scope :by_model, ->(model) { where(model: model) }
  scope :successful, -> { where(status: "success") }
  scope :failed, -> { where(status: "error") }
  scope :today, -> { where("created_at >= ?", Time.current.beginning_of_day) }

  # Calculate cost based on token usage
  def calculate_cost!
    cost_per_token = LlmClient::PRICING.dig(provider.to_sym, model.to_sym) || {}
    prompt_cost = (prompt_tokens || 0) * (cost_per_token[:prompt] || 0)
    completion_cost = (completion_tokens || 0) * (cost_per_token[:completion] || 0)

    update(cost: prompt_cost + completion_cost)
  end

  # Update usage summary after request
  after_create :update_usage_summary

  private

  def update_usage_summary
    summary = LlmUsageSummary.find_or_initialize_by(
      provider: provider,
      model: model,
      date: created_at.to_date
    )

    summary.request_count += 1
    summary.total_tokens += total_tokens || 0
    summary.prompt_tokens += prompt_tokens || 0
    summary.completion_tokens += completion_tokens || 0
    summary.total_cost += cost || 0
    summary.error_count += 1 if status == "error"

    # Calculate average response time
    if response_time_ms
      current_avg = summary.avg_response_time_ms || 0
      total_requests = summary.request_count
      summary.avg_response_time_ms = ((current_avg * (total_requests - 1)) + response_time_ms) / total_requests
    end

    summary.save!
  end
end
