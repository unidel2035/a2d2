# Equipment - Agricultural machinery and IoT devices
class Equipment < ApplicationRecord
  belongs_to :farm

  EQUIPMENT_TYPES = %w[
    tractor
    harvester
    planter
    sprayer
    drone
    sensor
    irrigation_system
    weather_station
  ].freeze

  STATUSES = %w[available in_use maintenance offline].freeze

  validates :name, presence: true
  validates :equipment_type, inclusion: { in: EQUIPMENT_TYPES }, allow_nil: true
  validates :status, inclusion: { in: STATUSES }

  serialize :telemetry_data, coder: JSON

  scope :available, -> { where(status: 'available') }
  scope :in_use, -> { where(status: 'in_use') }
  scope :autonomous, -> { where(autonomous: true) }
  scope :by_type, ->(type) { where(equipment_type: type) }

  def online?
    last_telemetry_at.present? && last_telemetry_at > 10.minutes.ago
  end

  def update_telemetry(data)
    update(
      telemetry_data: data,
      last_telemetry_at: Time.current
    )
  end

  def telemetry
    telemetry_data || {}
  end
end
