# LogisticsOrder - Transportation and delivery management
class LogisticsOrder < ApplicationRecord
  belongs_to :agro_agent

  ORDER_TYPES = %w[transport storage delivery collection].freeze
  STATUSES = %w[pending assigned in_transit delivered cancelled].freeze

  validates :order_type, presence: true, inclusion: { in: ORDER_TYPES }
  validates :status, inclusion: { in: STATUSES }

  serialize :origin, coder: JSON
  serialize :destination, coder: JSON
  serialize :route_data, coder: JSON

  scope :active, -> { where(status: %w[pending assigned in_transit]) }
  scope :by_status, ->(status) { where(status: status) }
  scope :pending, -> { where(status: 'pending') }

  def duration
    return nil unless pickup_time && delivery_time
    delivery_time - pickup_time
  end

  def in_progress?
    %w[assigned in_transit].include?(status)
  end
end
