# WeatherData - Weather conditions for agro modeling
# Part of Plant-Soil-Atmosphere (PSA) model
# Integration point for weather APIs and stations
class WeatherData < ApplicationRecord
  belongs_to :farm
  belongs_to :field_zone, optional: true

  validates :recorded_at, presence: true
  validates :temperature, numericality: true, allow_nil: true
  validates :humidity, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :precipitation, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  serialize :forecast_data, coder: JSON

  scope :recent, -> { where('recorded_at >= ?', 7.days.ago) }
  scope :for_farm, ->(farm_id) { where(farm_id: farm_id) }
  scope :for_zone, ->(zone_id) { where(field_zone_id: zone_id) }
  scope :with_precipitation, -> { where('precipitation > 0') }
  scope :ordered_by_time, -> { order(recorded_at: :desc) }

  # Calculate Growing Degree Days (GDD) - important for crop development
  # Base temperature is typically 10°C for most crops
  def growing_degree_days(base_temp = 10.0)
    return nil unless temperature.present?

    [temperature - base_temp, 0].max
  end

  # Determine if conditions are favorable for field work
  def favorable_for_fieldwork?
    return false if precipitation.present? && precipitation > 5 # Too wet
    return false if wind_speed.present? && wind_speed > 15 # Too windy
    return false if temperature.present? && (temperature < 5 || temperature > 35) # Too extreme

    true
  end

  # Calculate vapor pressure deficit (VPD) - important for irrigation
  def vapor_pressure_deficit
    return nil unless temperature.present? && humidity.present?

    # Saturated vapor pressure (kPa)
    svp = 0.6108 * Math.exp((17.27 * temperature) / (temperature + 237.3))
    # Actual vapor pressure
    avp = svp * (humidity / 100.0)
    # VPD
    svp - avp
  end

  # Risk assessment for frost
  def frost_risk?
    temperature.present? && temperature < 5
  end

  # Risk assessment for drought conditions
  def drought_conditions?
    return false unless humidity.present? && precipitation.present?

    humidity < 40 && precipitation < 1
  end

  # Get weather summary for display
  def summary
    parts = []
    parts << "#{temperature.round(1)}°C" if temperature.present?
    parts << "#{humidity.round}% влажность" if humidity.present?
    parts << "#{precipitation.round(1)} мм осадков" if precipitation.present?
    parts << "ветер #{wind_speed.round(1)} м/с" if wind_speed.present?

    parts.join(', ')
  end

  # Get forecast summary if available
  def forecast_summary
    return nil unless forecast_data.present?

    forecast_data.dig('summary') || 'Прогноз доступен'
  end
end
