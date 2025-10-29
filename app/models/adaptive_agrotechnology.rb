# AdaptiveAgrotechnology - Farm-specific adapted technologies (ААТ)
# Adaptation of base technology (БАТ) to specific farm conditions
# Implements adaptive approach from conceptual materials
class AdaptiveAgrotechnology < ApplicationRecord
  belongs_to :agrotechnology_ontology
  belongs_to :farm
  belongs_to :crop, optional: true
  belongs_to :field_zone, optional: true
  has_many :simulation_results, dependent: :nullify

  STATUSES = %w[planned active completed cancelled].freeze

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }

  serialize :adaptations, coder: JSON
  serialize :execution_plan, coder: JSON
  serialize :performance_metrics, coder: JSON

  scope :planned, -> { where(status: 'planned') }
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :for_farm, ->(farm_id) { where(farm_id: farm_id) }
  scope :for_crop, ->(crop_id) { where(crop_id: crop_id) }
  scope :current_season, -> { where('start_date >= ?', 1.year.ago) }

  # Start execution of adaptive technology
  def activate!
    update(status: 'active', start_date: Date.current) if planned?
  end

  # Complete execution
  def complete!(metrics = {})
    update(
      status: 'completed',
      end_date: Date.current,
      performance_metrics: performance_metrics.to_h.merge(metrics)
    )
  end

  # Get all operations from base ontology
  def operations
    agrotechnology_ontology.ordered_operations
  end

  # Get adapted operation parameters
  def adapted_operation(operation_id)
    base_operation = agrotechnology_ontology.agrotechnology_operations.find(operation_id)
    adaptations_for_operation = adaptations.to_h.dig('operations', operation_id.to_s) || {}

    {
      operation: base_operation,
      adaptations: adaptations_for_operation
    }
  end

  # Calculate success rate compared to base technology
  def success_rate
    return nil unless completed? && performance_metrics.present?

    expected = performance_metrics.dig('expected_yield')
    actual = performance_metrics.dig('actual_yield')

    return nil unless expected.present? && actual.present? && expected > 0

    (actual / expected * 100).round(2)
  end

  # Get reasons for adaptations
  def adaptation_reasons
    adaptations.to_h.dig('reasons') || []
  end

  # Check if technology is on schedule
  def on_schedule?
    return true unless start_date.present? && end_date.present?
    return true if completed?

    Date.current <= end_date
  end

  # Get execution progress (0-100%)
  def execution_progress
    return 0 unless start_date.present?
    return 100 if completed?

    plan = execution_plan.to_h
    return 0 if plan.blank? || !plan['steps'].is_a?(Array)

    completed_steps = plan['steps'].count { |step| step['completed'] == true }
    total_steps = plan['steps'].count

    return 0 if total_steps.zero?

    (completed_steps.to_f / total_steps * 100).round(2)
  end

  # Update execution plan step
  def complete_step!(step_id)
    plan = execution_plan.to_h
    return false unless plan['steps'].is_a?(Array)

    step = plan['steps'].find { |s| s['id'] == step_id }
    return false unless step

    step['completed'] = true
    step['completed_at'] = Time.current.iso8601

    update(execution_plan: plan)
  end

  # Get next pending step
  def next_step
    plan = execution_plan.to_h
    return nil unless plan['steps'].is_a?(Array)

    plan['steps'].find { |step| !step['completed'] }
  end
end
