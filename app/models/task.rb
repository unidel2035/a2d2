class Task < ApplicationRecord
  # Enums
  enum status: {
    planned: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  # Associations
  belongs_to :robot
  belongs_to :operator, class_name: "User", optional: true
  has_one :inspection_report, dependent: :destroy
  has_many :telemetry_data, dependent: :destroy

  # Validations
  validates :task_number, presence: true, uniqueness: true
  validates :status, presence: true

  # Callbacks
  before_validation :generate_task_number, on: :create
  after_update :update_robot_stats, if: :saved_change_to_status?

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :upcoming, -> { where(status: :planned).where("planned_date >= ?", Time.current) }
  scope :overdue, -> { where(status: :planned).where("planned_date < ?", Time.current) }
  scope :completed_in_range, ->(start_date, end_date) { where(status: :completed, actual_end: start_date..end_date) }

  # ROB-002: Task management
  def start!
    update!(
      status: :in_progress,
      actual_start: Time.current
    )
  end

  def complete!
    update!(
      status: :completed,
      actual_end: Time.current,
      duration: calculate_duration
    )
  end

  def cancel!
    update!(status: :cancelled)
  end

  def overdue?
    planned? && planned_date && planned_date < Time.current
  end

  def calculate_duration
    return nil unless actual_start && actual_end

    ((actual_end - actual_start) / 60).to_i # Duration in minutes
  end

  # ROB-005: Inspection reports
  def create_inspection_report(attributes = {})
    report = build_inspection_report(attributes.merge(
      report_number: generate_report_number,
      task_id: id
    ))
    report.save!
    report
  end

  private

  def generate_task_number
    self.task_number ||= "TSK-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def generate_report_number
    "RPT-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def update_robot_stats
    if completed?
      robot.increment!(:total_tasks)
      robot.increment!(:total_operation_hours, duration / 60.0) if duration
    end
  end
end
