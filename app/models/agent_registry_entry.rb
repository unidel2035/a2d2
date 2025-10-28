class AgentRegistryEntry < ApplicationRecord
  # JSON serialization for SQLite compatibility
  serialize :health_check_data, coder: JSON
  serialize :performance_metrics, coder: JSON

  # Associations
  belongs_to :agent

  # Validations
  validates :registration_status, presence: true, inclusion: {
    in: %w[registered active suspended deregistered]
  }
  validates :consecutive_failures, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true, registration_status: %w[registered active]) }
  scope :suspended, -> { where(registration_status: 'suspended') }
  scope :deregistered, -> { where(registration_status: 'deregistered') }
  scope :healthy, -> { where('consecutive_failures < ?', 3) }
  scope :unhealthy, -> { where('consecutive_failures >= ?', 3) }
  scope :recent_heartbeat, -> { where('last_health_check > ?', 2.minutes.ago) }

  # Callbacks
  before_create :set_registered_at

  # Health check methods
  def record_heartbeat!
    update!(
      last_health_check: Time.current,
      consecutive_failures: 0,
      health_check_data: health_check_data.merge(
        last_successful_heartbeat: Time.current
      )
    )
  end

  def record_failure!
    increment!(:consecutive_failures)

    if consecutive_failures >= 3
      suspend_agent!
    end

    update!(health_check_data: health_check_data.merge(
      last_failure: Time.current,
      failure_count: health_check_data.fetch('failure_count', 0) + 1
    ))
  end

  def suspend_agent!
    update!(
      registration_status: 'suspended',
      active: false
    )
    agent.deactivate!
  end

  def reactivate!
    update!(
      registration_status: 'active',
      active: true,
      consecutive_failures: 0
    )
    agent.activate!
  end

  def deregister!
    update!(
      registration_status: 'deregistered',
      active: false
    )
    agent.deactivate!
  end

  def update_performance_metrics(metrics)
    update!(
      performance_metrics: performance_metrics.merge(metrics).merge(
        updated_at: Time.current
      )
    )
  end

  def average_response_time
    performance_metrics.dig('response_times')&.sum&./(performance_metrics.dig('response_times')&.size || 1)
  end

  def success_rate
    total = performance_metrics.dig('total_tasks') || 0
    return 100.0 if total.zero?

    successful = performance_metrics.dig('successful_tasks') || 0
    (successful.to_f / total * 100).round(2)
  end

  private

  def set_registered_at
    self.registered_at ||= Time.current
    self.health_check_data ||= {}
    self.performance_metrics ||= {}
  end
end
