class LlmUsageSummary < ApplicationRecord
  # Validations
  validates :provider, presence: true
  validates :model, presence: true
  validates :date, presence: true
  validates :provider, uniqueness: { scope: [ :model, :date ] }

  # Scopes
  scope :by_provider, ->(provider) { where(provider: provider) }
  scope :by_model, ->(model) { where(model: model) }
  scope :by_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :current_month, -> { where(date: Time.current.beginning_of_month..Time.current.end_of_month) }

  # Get total cost for a period
  def self.total_cost_for_period(start_date, end_date)
    by_date_range(start_date, end_date).sum(:total_cost)
  end

  # Get total tokens for a period
  def self.total_tokens_for_period(start_date, end_date)
    by_date_range(start_date, end_date).sum(:total_tokens)
  end

  # Get breakdown by provider
  def self.breakdown_by_provider(start_date, end_date)
    by_date_range(start_date, end_date)
      .group(:provider)
      .sum(:total_cost)
  end

  # Get breakdown by model
  def self.breakdown_by_model(start_date, end_date)
    by_date_range(start_date, end_date)
      .group(:model)
      .sum(:total_cost)
  end
end
