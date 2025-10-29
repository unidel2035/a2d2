# MarketOffer - Supply and demand marketplace
class MarketOffer < ApplicationRecord
  belongs_to :agro_agent

  OFFER_TYPES = %w[supply demand].freeze
  STATUSES = %w[active matched completed cancelled expired].freeze
  UNITS = %w[tons kg liters pieces hectares].freeze

  validates :offer_type, presence: true, inclusion: { in: OFFER_TYPES }
  validates :product_type, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :unit, inclusion: { in: UNITS }, allow_nil: true

  serialize :conditions, coder: JSON

  scope :active, -> { where(status: 'active').where('valid_until >= ?', Date.current) }
  scope :supply, -> { where(offer_type: 'supply') }
  scope :demand, -> { where(offer_type: 'demand') }
  scope :by_product, ->(product) { where(product_type: product) }
  scope :expiring_soon, -> { where('valid_until <= ?', 7.days.from_now) }

  def expired?
    valid_until.present? && valid_until < Date.current
  end

  def total_value
    return nil unless quantity.present? && price_per_unit.present?
    quantity * price_per_unit
  end

  def days_until_expiry
    return nil unless valid_until.present?
    (valid_until - Date.current).to_i
  end
end
