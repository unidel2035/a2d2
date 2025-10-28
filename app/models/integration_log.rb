class IntegrationLog < ApplicationRecord
  # Enums
  enum status: {
    success: 0,
    failed: 1,
    pending: 2
  }

  # Associations
  belongs_to :integration

  # Validations
  validates :operation, presence: true
  validates :status, presence: true
  validates :executed_at, presence: true

  # Scopes
  scope :recent, -> { order(executed_at: :desc) }
  scope :successful, -> { where(status: :success) }
  scope :failed, -> { where(status: :failed) }
  scope :by_operation, ->(operation) { where(operation: operation) }
  scope :slow_operations, -> { where("duration > ?", 5.0) }

  # BUS-007: Integration monitoring
  def self.average_duration(period: 24.hours)
    where("executed_at >= ?", period.ago).average(:duration)
  end

  def self.error_rate(period: 24.hours)
    logs = where("executed_at >= ?", period.ago)
    return 0 if logs.empty?

    failed_count = logs.failed.count
    (failed_count.to_f / logs.count * 100).round(2)
  end
end
