# Модель для агентов агротехнологической системы
class AgroAgent < ApplicationRecord
  # Ассоциации
  belongs_to :user, optional: true
  has_many :agro_tasks, dependent: :nullify
  has_many :farms, dependent: :nullify
  has_many :decision_supports, dependent: :nullify
  has_many :logistics_orders, dependent: :nullify
  has_many :market_offers, dependent: :nullify
  has_many :processing_batches, dependent: :nullify

  # Сериализация JSON для совместимости с SQLite
  serialize :capabilities, coder: JSON
  serialize :configuration, coder: JSON

  # Валидации
  validates :name, presence: true
  validates :agent_type, presence: true
  validates :level, presence: true
  validates :status, presence: true, inclusion: { in: %w[active inactive maintenance] }
  validates :success_rate, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }

  # Скоупы
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :by_level, ->(level) { where(level: level) }
  scope :by_type, ->(type) { where(agent_type: type) }
  scope :online, -> { where('last_heartbeat > ?', 5.minutes.ago) }
  scope :offline, -> { where('last_heartbeat IS NULL OR last_heartbeat <= ?', 5.minutes.ago) }

  # Колбэки
  before_create :initialize_defaults

  # Методы проверки состояния
  def online?
    last_heartbeat.present? && last_heartbeat > 5.minutes.ago
  end

  def offline?
    !online?
  end

  def active?
    status == 'active'
  end

  # Работа с возможностями
  def capability_list
    capabilities.is_a?(Array) ? capabilities : []
  end

  def has_capability?(capability)
    capability_list.include?(capability.to_s)
  end

  def add_capability(capability)
    caps = capability_list
    caps << capability.to_s unless caps.include?(capability.to_s)
    update(capabilities: caps)
  end

  # Управление heartbeat
  def heartbeat!
    update(last_heartbeat: Time.current)
  end

  # Статистика задач
  def update_task_stats(success:)
    if success
      increment!(:tasks_completed)
    else
      increment!(:tasks_failed)
    end
    update_success_rate!
  end

  def update_success_rate!
    total = tasks_completed + tasks_failed
    return if total.zero?

    rate = (tasks_completed.to_f / total * 100).round(2)
    update(success_rate: rate)
  end

  # Отчет о состоянии
  def status_report
    {
      id: id,
      name: name,
      agent_type: agent_type,
      level: level,
      status: status,
      online: online?,
      success_rate: success_rate,
      tasks_completed: tasks_completed,
      tasks_failed: tasks_failed,
      pending_tasks: agro_tasks.pending.count,
      last_heartbeat: last_heartbeat,
      capabilities: capability_list
    }
  end

  private

  def initialize_defaults
    self.capabilities ||= []
    self.configuration ||= {}
    self.success_rate ||= 100.0
    self.tasks_completed ||= 0
    self.tasks_failed ||= 0
    self.status ||= 'active'
  end
end
