class OrchestratorEvent < ApplicationRecord
  belongs_to :agent, optional: true
  belongs_to :agent_task, optional: true

  # Serialize JSON fields
  serialize :event_data, coder: JSON

  # Validations
  validates :event_type, presence: true
  validates :severity, inclusion: { in: %w[info warning error critical] }
  validates :occurred_at, presence: true

  # Scopes
  scope :recent, -> { order(occurred_at: :desc) }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :by_type, ->(type) { where(event_type: type) }
  scope :critical, -> { where(severity: "critical") }
  scope :errors, -> { where(severity: %w[error critical]) }
  scope :for_agent, ->(agent_id) { where(agent_id: agent_id) }
  scope :for_task, ->(task_id) { where(agent_task_id: task_id) }
  scope :since, ->(time) { where("occurred_at >= ?", time) }

  # Class method to log events
  def self.log(event_type:, severity: "info", agent: nil, agent_task: nil, message: nil, data: {})
    create!(
      event_type: event_type,
      severity: severity,
      agent: agent,
      agent_task: agent_task,
      message: message,
      event_data: data,
      occurred_at: Time.current
    )
  end

  # Class method to get system health
  def self.system_health(since: 1.hour.ago)
    events = since(since)
    {
      total_events: events.count,
      critical_count: events.where(severity: "critical").count,
      error_count: events.where(severity: "error").count,
      warning_count: events.where(severity: "warning").count,
      recent_errors: events.errors.limit(10).pluck(:message, :occurred_at)
    }
  end
end
