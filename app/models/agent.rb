class Agent < ApplicationRecord
  has_many :agent_tasks, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :type, presence: true
  validates :status, inclusion: { in: %w[idle busy error offline] }

  # Scopes
  scope :active, -> { where.not(status: "offline") }
  scope :available, -> { where(status: "idle") }
  scope :by_type, ->(type) { where(type: type) }

  # Heartbeat management
  def heartbeat!
    update(last_heartbeat_at: Time.current, status: "idle")
  end

  def online?
    last_heartbeat_at && last_heartbeat_at > 5.minutes.ago
  end

  # Capability checking
  def can_handle?(task_type)
    capabilities.key?(task_type.to_s) && capabilities[task_type.to_s]
  end

  # Execute task (to be overridden by subclasses)
  def execute(task)
    raise NotImplementedError, "Subclasses must implement execute method"
  end

  # Validate result (to be overridden by subclasses)
  def validate_result(result)
    result.present?
  end

  # Report status
  def report_status
    {
      name: name,
      type: type,
      status: status,
      online: online?,
      capabilities: capabilities,
      last_heartbeat: last_heartbeat_at
    }
  end
end
