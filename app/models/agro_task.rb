# Модель для задач агротехнологических агентов
class AgroTask < ApplicationRecord
  # Ассоциации
  belongs_to :agro_agent, optional: true

  # Сериализация JSON для совместимости с SQLite
  serialize :input_data, coder: JSON
  serialize :output_data, coder: JSON

  # Валидации
  validates :task_type, presence: true
  validates :status, presence: true, inclusion: {
    in: %w[pending running completed failed cancelled]
  }
  validates :priority, presence: true, inclusion: {
    in: %w[low normal high urgent]
  }
  validates :retry_count, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0
  }

  # Скоупы
  scope :pending, -> { where(status: 'pending') }
  scope :running, -> { where(status: 'running') }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :by_priority, -> {
    # Сортировка по приоритету: urgent > high > normal > low
    order(Arel.sql("CASE priority WHEN 'urgent' THEN 4 WHEN 'high' THEN 3 WHEN 'normal' THEN 2 WHEN 'low' THEN 1 ELSE 0 END DESC, created_at ASC"))
  }
  scope :high_priority, -> { where(priority: %w[high urgent]) }
  scope :by_agent, ->(agent_id) { where(agro_agent_id: agent_id) }

  # Колбэки
  before_create :initialize_defaults

  # Методы состояния
  def pending?
    status == 'pending'
  end

  def running?
    status == 'running'
  end

  def completed?
    status == 'completed'
  end

  def failed?
    status == 'failed'
  end

  def cancelled?
    status == 'cancelled'
  end

  # Управление жизненным циклом задачи
  def start!
    return false unless pending?

    update!(
      status: 'running',
      started_at: Time.current
    )
  end

  def complete!(output = {})
    return false unless running?

    update!(
      status: 'completed',
      output_data: output,
      completed_at: Time.current
    )

    agro_agent&.update_task_stats(success: true)
    true
  end

  def fail!(error_message)
    update!(
      status: 'failed',
      error_message: error_message,
      completed_at: Time.current
    )

    agro_agent&.update_task_stats(success: false)
  end

  def cancel!
    return false if completed?

    update!(
      status: 'cancelled',
      completed_at: Time.current
    )
  end

  def retry!
    return false if retry_count >= 3

    increment!(:retry_count)
    update!(
      status: 'pending',
      started_at: nil,
      completed_at: nil,
      error_message: nil
    )
  end

  # Вычисление длительности
  def duration
    return nil unless started_at && completed_at
    completed_at - started_at
  end

  # Переназначение агенту
  def reassign_to(new_agent)
    return false unless pending?
    update(agro_agent: new_agent)
  end

  private

  def initialize_defaults
    self.input_data ||= {}
    self.output_data ||= {}
    self.status ||= 'pending'
    self.priority ||= 'normal'
    self.retry_count ||= 0
  end
end
