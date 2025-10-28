# frozen_string_literal: true

# WorkflowExecution represents a single execution run of a workflow
# Tracks the status, timing, and data for the execution
class WorkflowExecution < ApplicationRecord
  # Associations
  belongs_to :workflow

  # Validations
  validates :status, inclusion: {
    in: %w[new running waiting success error cancelled]
  }

  # Enums
  enum :status, {
    new: 'new',
    running: 'running',
    waiting: 'waiting',
    success: 'success',
    error: 'error',
    cancelled: 'cancelled'
  }

  # Serialized attributes
  serialize :data, coder: JSON

  # Scopes
  scope :recent, -> { order(started_at: :desc) }
  scope :completed, -> { where(status: %w[success error cancelled]) }
  scope :in_progress, -> { where(status: %w[new running waiting]) }

  # Callbacks
  before_create :set_started_at

  # Instance methods

  # Mark execution as running
  def start!
    update!(status: 'running', started_at: Time.current)
  end

  # Mark execution as successful
  def complete!(output_data = nil)
    update!(
      status: 'success',
      finished_at: Time.current,
      stopped_at: Time.current,
      data: (data || {}).merge(output: output_data)
    )
  end

  # Mark execution as failed
  def fail!(error_msg)
    update!(
      status: 'error',
      finished_at: Time.current,
      stopped_at: Time.current,
      error_message: error_msg
    )
  end

  # Mark execution as cancelled
  def cancel!
    update!(
      status: 'cancelled',
      stopped_at: Time.current,
      finished_at: Time.current
    )
  end

  # Calculate execution duration
  def duration
    return nil unless started_at && finished_at

    finished_at - started_at
  end

  # Check if execution is completed
  def completed?
    %w[success error cancelled].include?(status)
  end

  # Get execution statistics
  def statistics
    {
      status: status,
      mode: mode,
      duration: duration,
      started_at: started_at,
      finished_at: finished_at,
      has_errors: status == 'error',
      error_message: error_message
    }
  end

  private

  def set_started_at
    self.started_at ||= Time.current
  end
end
