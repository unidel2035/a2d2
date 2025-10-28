class Agent < ApplicationRecord
  has_many :agent_tasks, dependent: :destroy
  has_many :orchestrator_events, dependent: :destroy
  has_many :agent_collaborations, foreign_key: :primary_agent_id, dependent: :destroy

  # Serialize JSON fields for SQLite compatibility
  serialize :capabilities, coder: JSON
  serialize :configuration, coder: JSON
  serialize :specialization_tags, coder: JSON
  serialize :performance_metrics, coder: JSON

  # Validations
  validates :name, presence: true
  validates :type, presence: true
  validates :status, inclusion: { in: %w[idle busy error offline] }

  # Scopes
  scope :active, -> { where.not(status: "offline") }
  scope :available, -> { where(status: "idle") }
  scope :by_type, ->(type) { where(type: type) }
  scope :least_loaded, -> { active.order(load_score: :asc, current_task_count: :asc) }
  scope :high_performers, -> { where("success_rate >= ?", 80.0).order(success_rate: :desc) }
  scope :with_capability, ->(capability) { active.select { |agent| agent.can_handle?(capability) } }

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
      last_heartbeat: last_heartbeat_at,
      load_score: load_score,
      success_rate: success_rate,
      current_tasks: current_task_count,
      max_tasks: max_concurrent_tasks,
      performance: performance_metrics
    }
  end

  # Update load score based on current workload
  def update_load_score!
    score = (current_task_count.to_f / max_concurrent_tasks * 100).to_i
    update(load_score: score)
  end

  # Update success rate based on completed tasks
  def update_success_rate!
    total = total_tasks_completed + total_tasks_failed
    return if total.zero?

    rate = (total_tasks_completed.to_f / total * 100).round(2)
    update(success_rate: rate)
  end

  # Increment task counters
  def task_completed!(duration_seconds)
    increment!(:total_tasks_completed)
    decrement!(:current_task_count)

    # Update average completion time
    total = total_tasks_completed
    current_avg = average_completion_time
    new_avg = ((current_avg * (total - 1)) + duration_seconds) / total
    update(average_completion_time: new_avg.to_i)

    update_success_rate!
    update_load_score!
  end

  def task_failed!
    increment!(:total_tasks_failed)
    decrement!(:current_task_count)
    update_success_rate!
    update_load_score!
  end

  def task_started!
    increment!(:current_task_count)
    update_load_score!
    update(status: "busy")
  end

  # Check if agent can accept more tasks
  def can_accept_task?
    online? && current_task_count < max_concurrent_tasks
  end

  # Get agent specializations
  def specializations
    specialization_tags || []
  end

  # Check if agent has specialization
  def specializes_in?(tag)
    specializations.include?(tag.to_s)
  end
end
