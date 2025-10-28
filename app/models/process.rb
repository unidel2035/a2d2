class Process < ApplicationRecord
  # Enums
  enum status: {
    draft: 0,
    active: 1,
    inactive: 2
  }

  # Associations
  belongs_to :user
  belongs_to :parent, class_name: "Process", optional: true
  has_many :versions, class_name: "Process", foreign_key: :parent_id, dependent: :destroy
  has_many :process_steps, dependent: :destroy
  has_many :process_executions, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :status, presence: true
  validates :version_number, numericality: { greater_than: 0 }

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def create_new_version!
    transaction do
      new_version = self.dup
      new_version.parent_id = id
      new_version.version_number = versions.maximum(:version_number).to_i + 1
      new_version.definition = definition.deep_dup
      new_version.metadata = metadata.deep_dup
      new_version.save!

      # Copy process steps
      process_steps.each do |step|
        new_step = step.dup
        new_step.process = new_version
        new_step.save!
      end

      new_version
    end
  end

  def execute!(input_data = {}, user: nil)
    execution = process_executions.create!(
      user: user,
      input_data: input_data,
      status: :pending
    )

    ProcessExecutionJob.perform_later(execution.id)
    execution
  end

  def latest_version
    versions.order(version_number: :desc).first || self
  end
end
