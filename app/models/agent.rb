class Agent < ApplicationRecord
  # Associations - Phase 3 orchestration
  has_many :agent_tasks, dependent: :nullify
  has_one :agent_registry_entry, dependent: :destroy
  has_many :verification_logs, dependent: :destroy
  has_many :memory_stores, dependent: :destroy

  # Associations - Main branch collaboration
  has_many :orchestrator_events, dependent: :destroy
  has_many :agent_collaborations, foreign_key: :primary_agent_id, dependent: :destroy

  # JSON serialization for SQLite compatibility - Combined from both versions
  serialize :capabilities, coder: JSON
  serialize :metadata, coder: JSON
  serialize :configuration, coder: JSON
  serialize :specialization_tags, coder: JSON
  serialize :performance_metrics, coder: JSON

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :agent_type, presence: true
  validates :status, presence: true, inclusion: { in: %w[inactive idle busy failed offline] }
  validates :health_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Scopes - Combined from both versions
  scope :active, -> { where(status: %w[idle busy]) }
  scope :idle, -> { where(status: 'idle') }
  scope :busy, -> { where(status: 'busy') }
  scope :failed, -> { where(status: 'failed') }
  scope :available, -> { where(status: 'idle') }
  scope :by_type, ->(type) { where(agent_type: type) }
  scope :with_capability, ->(capability) {
    # SQLite-compatible capability search using JSON serialization
    all.select { |agent| agent.has_capability?(capability) }
  }
  scope :healthy, -> { where('health_score >= ?', 70) }
  scope :recently_active, -> { where('last_heartbeat > ?', 5.minutes.ago) }
  scope :least_loaded, -> { active.order(Arel.sql('CAST(metadata AS TEXT)'), current_task_count: :asc) }
  scope :high_performers, -> { where('success_rate >= ?', 80.0).order(success_rate: :desc) } rescue scope :high_performers, -> { all }

  # Callbacks
  before_create :initialize_capabilities
  after_create :create_registry_entry

  # Phase 3 Lifecycle methods
  def activate!
    update!(status: 'idle', last_heartbeat: Time.current)
  end

  def deactivate!
    update!(status: 'inactive')
  end

  def mark_busy!
    update!(status: 'busy')
  end

  def mark_idle!
    update!(status: 'idle')
  end

  def mark_failed!
    update!(status: 'failed', health_score: [health_score - 20, 0].max)
  end

  # Heartbeat tracking
  def heartbeat!
    update!(last_heartbeat: Time.current)
    agent_registry_entry&.record_heartbeat!
  end

  # Capability checks
  def has_capability?(capability)
    capabilities.is_a?(Array) && capabilities.include?(capability)
  end

  def can_handle_task?(task)
    return false unless active_status?
    return false if task.required_capability.present? && !has_capability?(task.required_capability)

    health_score >= 50
  end

  def can_handle?(capability)
    has_capability?(capability)
  end

  def active_status?
    %w[idle busy].include?(status)
  end

  def online?
    active_status?
  end

  def current_load
    agent_tasks.where(status: %w[pending running]).count
  end

  def update_health_score(delta)
    new_score = [[health_score + delta, 0].max, 100].min
    update!(health_score: new_score)
  end

  # Main branch status reporting
  def report_status
    {
      name: name,
      type: agent_type,
      status: status,
      online: online?,
      capabilities: capabilities,
      last_heartbeat: last_heartbeat,
      load_score: respond_to?(:load_score) ? load_score : nil,
      success_rate: respond_to?(:success_rate) ? success_rate : nil,
      current_tasks: respond_to?(:current_task_count) ? current_task_count : current_load,
      max_tasks: respond_to?(:max_concurrent_tasks) ? max_concurrent_tasks : nil,
      performance: performance_metrics
    }
  end

  # Main branch task tracking (if columns exist)
  def update_load_score!
    return unless respond_to?(:load_score) && respond_to?(:max_concurrent_tasks)
    score = (current_task_count.to_f / max_concurrent_tasks * 100).to_i
    update(load_score: score)
  end

  def update_success_rate!
    return unless respond_to?(:total_tasks_completed) && respond_to?(:total_tasks_failed)
    total = total_tasks_completed + total_tasks_failed
    return if total.zero?

    rate = (total_tasks_completed.to_f / total * 100).round(2)
    update(success_rate: rate)
  end

  def task_completed!(duration_seconds = 0)
    return unless respond_to?(:total_tasks_completed)
    increment!(:total_tasks_completed)
    decrement!(:current_task_count) if respond_to?(:current_task_count)

    if respond_to?(:average_completion_time)
      total = total_tasks_completed
      current_avg = average_completion_time || 0
      new_avg = ((current_avg * (total - 1)) + duration_seconds) / total
      update(average_completion_time: new_avg.to_i)
    end

    update_success_rate!
    update_load_score!
  end

  def task_failed!
    return unless respond_to?(:total_tasks_failed)
    increment!(:total_tasks_failed)
    decrement!(:current_task_count) if respond_to?(:current_task_count)
    update_success_rate!
    update_load_score!
  end

  def task_started!
    increment!(:current_task_count) if respond_to?(:current_task_count)
    update_load_score!
    update(status: 'busy')
  end

  def can_accept_task?
    return online? && current_load < 10 unless respond_to?(:max_concurrent_tasks)
    online? && current_task_count < max_concurrent_tasks
  end

  # Specialization methods
  def specializations
    specialization_tags || []
  end

  def specializes_in?(tag)
    specializations.include?(tag.to_s)
  end

  private

  def initialize_capabilities
    self.capabilities ||= []
  end

  def create_registry_entry
    AgentRegistryEntry.create!(
      agent: self,
      registered_at: Time.current,
      registration_status: 'registered'
    )
  end
end
