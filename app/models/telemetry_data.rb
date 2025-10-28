class TelemetryData < ApplicationRecord
  # Associations
  belongs_to :robot
  belongs_to :task, optional: true

  # Validations
  validates :recorded_at, presence: true

  # Scopes
  scope :recent, -> { order(recorded_at: :desc) }
  scope :for_robot, ->(robot_id) { where(robot_id: robot_id) }
  scope :in_range, ->(start_time, end_time) { where(recorded_at: start_time..end_time) }
  scope :with_location, -> { where.not(latitude: nil, longitude: nil) }

  # ROB-003: Telemetry and monitoring
  def self.record(robot_id, telemetry_params)
    create!(
      robot_id: robot_id,
      recorded_at: telemetry_params[:recorded_at] || Time.current,
      data: telemetry_params[:data] || {},
      location: telemetry_params[:location],
      latitude: telemetry_params[:latitude],
      longitude: telemetry_params[:longitude],
      altitude: telemetry_params[:altitude],
      sensors: telemetry_params[:sensors] || {}
    )
  end

  def has_location?
    latitude.present? && longitude.present?
  end

  def distance_from(other_telemetry)
    return nil unless has_location? && other_telemetry.has_location?

    # Haversine formula for calculating distance between two points
    lat1_rad = latitude * Math::PI / 180
    lat2_rad = other_telemetry.latitude * Math::PI / 180
    lon1_rad = longitude * Math::PI / 180
    lon2_rad = other_telemetry.longitude * Math::PI / 180

    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    a = Math.sin(dlat / 2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    6371 * c # Distance in kilometers
  end

  # Analytics
  def self.aggregate_metrics(robot_id, period: 24.hours)
    telemetry = for_robot(robot_id).in_range(period.ago, Time.current)

    {
      count: telemetry.count,
      avg_altitude: telemetry.average(:altitude),
      max_altitude: telemetry.maximum(:altitude),
      min_altitude: telemetry.minimum(:altitude),
      distance_covered: calculate_total_distance(telemetry.order(:recorded_at))
    }
  end

  def self.calculate_total_distance(ordered_telemetry)
    total = 0
    ordered_telemetry.each_cons(2) do |t1, t2|
      distance = t1.distance_from(t2)
      total += distance if distance
    end
    total
  end
end
