# FieldZone - Differentiated field zones for precision agriculture
# Represents zones within a farm with similar characteristics for Variable Rate Technology (VRT)
# Based on conceptual materials: ontological approach to precision farming
class FieldZone < ApplicationRecord
  belongs_to :farm
  has_many :remote_sensing_data, dependent: :destroy
  has_many :weather_data, dependent: :destroy
  has_many :adaptive_agrotechnologies, dependent: :nullify
  has_many :agrotechnology_parameters, dependent: :destroy
  has_many :decision_supports, dependent: :nullify
  has_many :plant_production_models, dependent: :nullify

  PRODUCTIVITY_CLASSES = %w[high medium low very_low].freeze

  validates :name, presence: true
  validates :productivity_class, inclusion: { in: PRODUCTIVITY_CLASSES }, allow_nil: true
  validates :area, numericality: { greater_than: 0 }, allow_nil: true

  serialize :geometry, coder: JSON
  serialize :characteristics, coder: JSON

  scope :by_productivity, ->(productivity_class) { where(productivity_class: productivity_class) }
  scope :high_productivity, -> { where(productivity_class: 'high') }
  scope :low_productivity, -> { where(productivity_class: %w[low very_low]) }

  # Calculate average NDVI for this zone from recent remote sensing data
  def average_ndvi(days_back = 7)
    remote_sensing_data
      .where(data_type: :ndvi)
      .where('captured_at >= ?', days_back.days.ago)
      .average(:ndvi_value)
  end

  # Get latest remote sensing data by type
  def latest_remote_sensing(data_type)
    remote_sensing_data
      .where(data_type: data_type)
      .order(captured_at: :desc)
      .first
  end

  # Determine if zone needs special attention based on NDVI
  def needs_attention?
    avg_ndvi = average_ndvi
    return false unless avg_ndvi.present?

    avg_ndvi < 0.4 # NDVI below 0.4 indicates stress or poor vegetation
  end

  # Get soil characteristics
  def soil_characteristics
    characteristics || {}
  end
end
