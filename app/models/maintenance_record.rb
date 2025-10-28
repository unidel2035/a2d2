class MaintenanceRecord < ApplicationRecord
  # Enums
  enum maintenance_type: {
    routine: 0,
    repair: 1,
    component_replacement: 2
  }

  enum status: {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  # Associations
  belongs_to :robot
  belongs_to :technician, class_name: "User", optional: true

  # Validations
  validates :scheduled_date, presence: true
  validates :maintenance_type, presence: true
  validates :status, presence: true

  # Callbacks
  after_update :update_robot_maintenance_date, if: -> { saved_change_to_status? && completed? }
  after_create :notify_technician

  # Scopes
  scope :upcoming, -> { where(status: :scheduled).where("scheduled_date >= ?", Date.current) }
  scope :overdue, -> { where(status: :scheduled).where("scheduled_date < ?", Date.current) }
  scope :completed_recently, -> { where(status: :completed).where("completed_date >= ?", 30.days.ago) }

  # ROB-004: Technical maintenance
  def start!
    update!(status: :in_progress)
  end

  def complete!(completion_data = {})
    update!(
      status: :completed,
      completed_date: Date.current,
      description: completion_data[:description],
      cost: completion_data[:cost],
      next_maintenance_date: calculate_next_maintenance_date,
      replaced_components: completion_data[:replaced_components] || []
    )

    # Update robot status
    robot.update!(status: :active) if robot.maintenance? || robot.repair?
  end

  def cancel!
    update!(status: :cancelled)
  end

  def overdue?
    scheduled? && scheduled_date < Date.current
  end

  private

  def calculate_next_maintenance_date
    case maintenance_type
    when "routine"
      scheduled_date + 6.months
    when "repair"
      scheduled_date + 3.months
    when "component_replacement"
      scheduled_date + 6.months
    else
      scheduled_date + 6.months
    end
  end

  def update_robot_maintenance_date
    robot.update!(last_maintenance_date: completed_date)
  end

  def notify_technician
    # ROB-004: Notify technician 7 days before scheduled maintenance
    # NotificationJob.set(wait_until: scheduled_date - 7.days).perform_later(technician.id, id) if technician
  end
end
