# Crop - Agricultural product cultivation tracking
class Crop < ApplicationRecord
  belongs_to :farm

  STATUSES = %w[planning planted growing harvesting harvested].freeze

  validates :crop_type, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :active, -> { where.not(status: 'harvested') }
  scope :by_status, ->(status) { where(status: status) }
  scope :current_season, -> { where('planting_date >= ?', 1.year.ago) }

  def yield_efficiency
    return nil unless expected_yield.present? && actual_yield.present?
    return nil if expected_yield.zero?

    (actual_yield / expected_yield * 100).round(2)
  end

  def days_to_harvest
    return nil unless harvest_date.present?
    (harvest_date - Date.current).to_i
  end

  def growth_duration
    return nil unless planting_date.present?

    if harvest_date.present?
      (harvest_date - planting_date).to_i
    else
      (Date.current - planting_date).to_i
    end
  end
end
