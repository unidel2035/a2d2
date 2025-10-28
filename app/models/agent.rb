class Agent < ApplicationRecord
  # JSON serialization for SQLite compatibility
  serialize :capabilities, coder: JSON
  serialize :metadata, coder: JSON

  # Associations
  has_many :agent_tasks, dependent: :nullify
  has_one :agent_registry_entry, dependent: :destroy
  has_many :verification_logs, dependent: :destroy
  has_many :memory_stores, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :agent_type, presence: true
  validates :status, presence: true, inclusion: { in: %w[inactive idle busy failed] }
  validates :health_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Scopes
  scope :active, -> { where(status: %w[idle busy]) }
  scope :idle, -> { where(status: 'idle') }
  scope :busy, -> { where(status: 'busy') }
  scope :failed, -> { where(status: 'failed') }
  scope :by_type, ->(type) { where(agent_type: type) }
  scope :with_capability, ->(capability) {
    # SQLite-compatible capability search using JSON serialization
    all.select { |agent| agent.has_capability?(capability) }
  }
  scope :healthy, -> { where('health_score >= ?', 70) }
  scope :recently_active, -> { where('last_heartbeat > ?', 5.minutes.ago) }

  # Callbacks
  before_create :initialize_capabilities
  after_create :create_registry_entry

  # Lifecycle methods
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

  def heartbeat!
    update!(last_heartbeat: Time.current)
    agent_registry_entry&.record_heartbeat!
  end

  def has_capability?(capability)
    capabilities.is_a?(Array) && capabilities.include?(capability)
  end

  def can_handle_task?(task)
    return false unless active_status?
    return false if task.required_capability.present? && !has_capability?(task.required_capability)

    health_score >= 50
  end

  def active_status?
    %w[idle busy].include?(status)
  end

  def current_load
    agent_tasks.where(status: %w[pending running]).count
  end

  def update_health_score(delta)
    new_score = [[health_score + delta, 0].max, 100].min
    update!(health_score: new_score)
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
