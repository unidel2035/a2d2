class MemoryStore < ApplicationRecord
  # JSON serialization for SQLite compatibility
  serialize :metadata, coder: JSON

  # Associations
  belongs_to :agent

  # Validations
  validates :memory_type, presence: true, inclusion: { in: %w[context long_term shared] }
  validates :key, presence: true
  validates :key, uniqueness: { scope: [:agent_id, :memory_type] }

  # Scopes
  scope :context, -> { where(memory_type: 'context') }
  scope :long_term, -> { where(memory_type: 'long_term') }
  scope :shared, -> { where(memory_type: 'shared') }
  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :by_priority, -> { order(priority: :desc, last_accessed_at: :desc) }
  scope :recently_accessed, -> { where('last_accessed_at > ?', 1.hour.ago) }
  scope :large_memories, -> { where('size_bytes > ?', 1.megabyte) }

  # Callbacks
  before_create :initialize_defaults
  before_save :calculate_size

  # Memory management methods
  def access!
    increment!(:access_count)
    touch(:last_accessed_at)
  end

  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  def active?
    !expired?
  end

  def extend_expiration(duration)
    new_expiration = (expires_at || Time.current) + duration
    update!(expires_at: new_expiration)
  end

  def set_value(new_value)
    update!(value: new_value)
  end

  def get_value
    access!
    value
  end

  def size_mb
    (size_bytes / 1.megabyte.to_f).round(2)
  end

  # Class methods for shared memory
  def self.get_shared(key)
    shared.active.find_by(key: key)&.get_value
  end

  def self.set_shared(key, value, expires_in: nil)
    memory = shared.find_or_initialize_by(
      agent_id: nil,
      key: key
    )

    memory.value = value
    memory.expires_at = Time.current + expires_in if expires_in
    memory.save!
    memory
  end

  # Pruning strategies
  def self.prune_expired!
    expired.destroy_all
  end

  def self.prune_by_priority!(agent, keep_count: 100)
    agent.memory_stores
         .order(priority: :asc, last_accessed_at: :asc)
         .offset(keep_count)
         .destroy_all
  end

  def self.prune_by_size!(agent, max_total_mb: 100)
    current_size_mb = agent.memory_stores.sum(:size_bytes) / 1.megabyte.to_f

    return if current_size_mb <= max_total_mb

    memories = agent.memory_stores.order(priority: :asc, last_accessed_at: :asc)
    total_size = 0

    memories.each do |memory|
      total_size += memory.size_mb
      memory.destroy if total_size > max_total_mb
    end
  end

  private

  def initialize_defaults
    self.metadata ||= {}
    self.last_accessed_at ||= Time.current
  end

  def calculate_size
    self.size_bytes = value.to_s.bytesize
  end
end
