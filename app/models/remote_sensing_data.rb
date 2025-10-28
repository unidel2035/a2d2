# RemoteSensingData - Satellite and UAV data for precision agriculture (Данные ДЗЗ)
# Integrates with remote sensing systems (VEGA-Pro, satellites, drones)
# Based on conceptual materials: Borgest N.M. - ontology of precision agriculture design
class RemoteSensingData < ApplicationRecord
  belongs_to :field_zone, optional: true
  belongs_to :crop, optional: true
  belongs_to :farm, optional: true

  # Source types for remote sensing
  enum source_type: {
    satellite: 0,    # e.g., Resurs-P, Sentinel, Landsat
    drone: 1,        # UAVs like Geokan 201 Agro
    ground_sensor: 2 # IoT sensors in field
  }

  # Data types from remote sensing
  enum data_type: {
    multispectral: 0, # Multiple spectral bands
    thermal: 1,       # Thermal imaging
    ndvi: 2,          # Normalized Difference Vegetation Index
    soil_moisture: 3, # Soil water content
    temperature: 4,   # Temperature measurements
    ndre: 5,          # Normalized Difference Red Edge Index
    evi: 6            # Enhanced Vegetation Index
  }

  validates :source_type, presence: true
  validates :data_type, presence: true
  validates :captured_at, presence: true
  validates :ndvi_value, numericality: { greater_than_or_equal_to: -1, less_than_or_equal_to: 1 }, allow_nil: true
  validates :confidence_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  serialize :data, coder: JSON
  serialize :metadata, coder: JSON

  scope :recent, -> { where('captured_at >= ?', 30.days.ago) }
  scope :by_source, ->(source_type) { where(source_type: source_type) }
  scope :by_data_type, ->(data_type) { where(data_type: data_type) }
  scope :for_farm, ->(farm_id) { where(farm_id: farm_id) }
  scope :for_crop, ->(crop_id) { where(crop_id: crop_id) }
  scope :high_quality, -> { where('confidence_score >= ?', 80) }

  # Get NDVI classification (interpretation of NDVI values)
  def ndvi_classification
    return nil unless ndvi_value.present?

    case ndvi_value
    when 0.8..1.0
      'excellent_vegetation'
    when 0.6..0.8
      'healthy_vegetation'
    when 0.4..0.6
      'moderate_vegetation'
    when 0.2..0.4
      'sparse_vegetation'
    when -1.0..0.2
      'no_vegetation_or_stress'
    end
  end

  # Get human-readable interpretation
  def interpretation
    case data_type
    when 'ndvi'
      interpret_ndvi
    when 'soil_moisture'
      interpret_soil_moisture
    when 'temperature'
      interpret_temperature
    else
      'Данные требуют анализа'
    end
  end

  # Check if data is still relevant
  def is_current?(days = 7)
    captured_at >= days.days.ago
  end

  # Get source description
  def source_description
    case source_type
    when 'satellite'
      source_name.presence || 'Спутниковые данные'
    when 'drone'
      source_name.presence || 'БПЛА съемка'
    when 'ground_sensor'
      source_name.presence || 'Наземные датчики'
    end
  end

  private

  def interpret_ndvi
    return 'Нет данных NDVI' unless ndvi_value.present?

    case ndvi_classification
    when 'excellent_vegetation'
      'Отличное состояние растительности (NDVI: %.2f)' % ndvi_value
    when 'healthy_vegetation'
      'Здоровая растительность (NDVI: %.2f)' % ndvi_value
    when 'moderate_vegetation'
      'Умеренное состояние, возможен стресс (NDVI: %.2f)' % ndvi_value
    when 'sparse_vegetation'
      'Разреженная растительность, требуется внимание (NDVI: %.2f)' % ndvi_value
    else
      'Отсутствие растительности или сильный стресс (NDVI: %.2f)' % ndvi_value
    end
  end

  def interpret_soil_moisture
    moisture = data.dig('moisture_percent') if data.is_a?(Hash)
    return 'Нет данных о влажности' unless moisture

    if moisture > 80
      'Переувлажнение (%.1f%%)' % moisture
    elsif moisture > 60
      'Оптимальная влажность (%.1f%%)' % moisture
    elsif moisture > 40
      'Умеренная влажность (%.1f%%)' % moisture
    else
      'Недостаток влаги (%.1f%%)' % moisture
    end
  end

  def interpret_temperature
    temp = data.dig('temperature') if data.is_a?(Hash)
    return 'Нет данных о температуре' unless temp

    if temp > 35
      'Высокая температура, возможен тепловой стресс (%.1f°C)' % temp
    elsif temp > 25
      'Оптимальная температура (%.1f°C)' % temp
    elsif temp > 15
      'Умеренная температура (%.1f°C)' % temp
    else
      'Низкая температура (%.1f°C)' % temp
    end
  end
end
