class Robot < ApplicationRecord
  # Enums
  enum :status, {
    active: 0,
    maintenance: 1,
    repair: 2,
    retired: 3
  }

  # Associations
  has_many :robot_tasks, dependent: :destroy
  has_many :tasks, class_name: 'RobotTask', dependent: :destroy  # Backwards compatibility
  has_many :maintenance_records, dependent: :destroy
  has_many :telemetry_data, dependent: :destroy

  # Validations
  validates :serial_number, presence: true, uniqueness: true
  validates :status, presence: true

  # Scopes
  scope :active_robots, -> { where(status: :active) }
  scope :needs_maintenance, -> { where("last_maintenance_date <= ?", 6.months.ago) }
  scope :by_manufacturer, ->(manufacturer) { where(manufacturer: manufacturer) }

  # ROB-001: Robot registration
  def self.register(attributes)
    create!(attributes.merge(status: :active))
  end

  # ROB-003: Telemetry and monitoring
  def record_telemetry(data)
    telemetry_data.create!(
      recorded_at: Time.current,
      data: data,
      location: data[:location],
      latitude: data[:latitude],
      longitude: data[:longitude],
      altitude: data[:altitude],
      sensors: data[:sensors]
    )

    # Update total operation hours
    if data[:operation_hours]
      increment!(:total_operation_hours, data[:operation_hours])
    end
  end

  # ROB-004: Technical maintenance
  def schedule_maintenance(scheduled_date:, maintenance_type: :routine, technician: nil)
    maintenance_records.create!(
      scheduled_date: scheduled_date,
      maintenance_type: maintenance_type,
      technician: technician,
      status: :scheduled,
      operation_hours_at_maintenance: total_operation_hours
    )
  end

  def needs_maintenance?
    return true unless last_maintenance_date
    return true if last_maintenance_date <= 6.months.ago

    # Check if maintenance needed based on operation hours
    hours_since_maintenance = total_operation_hours - (maintenance_records.last&.operation_hours_at_maintenance || 0)
    hours_since_maintenance >= 500 # Maintenance every 500 hours
  end

  def maintenance_due_date
    return Date.current if needs_maintenance?

    last_maintenance_date + 6.months if last_maintenance_date
  end

  # ROB-002: Task management
  def assign_task(task_params)
    tasks.create!(task_params.merge(status: :planned))
  end

  def active_tasks
    tasks.where(status: [:planned, :in_progress])
  end

  # Statistics
  def utilization_rate(period: 30.days)
    return 0 unless total_operation_hours.positive?

    recent_tasks = tasks.where("created_at >= ?", period.ago).where(status: :completed)
    total_task_hours = recent_tasks.sum(:duration) / 60.0 # Convert minutes to hours

    hours_in_period = period / 1.hour
    (total_task_hours / hours_in_period * 100).round(2)
  end

  def average_task_duration
    completed_tasks = tasks.where(status: :completed)
    return 0 if completed_tasks.empty?

    completed_tasks.average(:duration).to_f
  end
end
