# ProcessingBatch - Product processing and transformation tracking
class ProcessingBatch < ApplicationRecord
  belongs_to :agro_agent

  STATUSES = %w[planned processing completed quality_check failed].freeze

  validates :batch_number, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  serialize :quality_metrics, coder: JSON

  scope :active, -> { where(status: %w[planned processing quality_check]) }
  scope :by_status, ->(status) { where(status: status) }

  def conversion_rate
    return nil unless input_quantity.present? && output_quantity.present?
    return nil if input_quantity.zero?

    (output_quantity / input_quantity * 100).round(2)
  end

  def processing_duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  def quality_score
    return nil unless quality_metrics.present?
    quality_metrics['overall_score']
  end
end
