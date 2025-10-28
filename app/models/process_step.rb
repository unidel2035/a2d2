class ProcessStep < ApplicationRecord
  # Associations
  belongs_to :process
  belongs_to :next_step, class_name: "ProcessStep", optional: true
  has_many :process_step_executions, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :step_type, presence: true
  validates :order, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Scopes
  scope :ordered, -> { order(:order) }
  scope :by_type, ->(type) { where(step_type: type) }

  # Step types
  STEP_TYPES = %w[
    action
    decision
    agent_task
    integration
    transform
    wait
    parallel
    loop
  ].freeze

  validates :step_type, inclusion: { in: STEP_TYPES }

  # Methods
  def execute!(execution, context = {})
    step_execution = process_step_executions.create!(
      process_execution: execution,
      status: :running,
      started_at: Time.current,
      input_data: context
    )

    begin
      result = case step_type
               when "action"
                 execute_action(context)
               when "decision"
                 execute_decision(context)
               when "agent_task"
                 execute_agent_task(context)
               when "integration"
                 execute_integration(context)
               when "transform"
                 execute_transform(context)
               when "wait"
                 execute_wait(context)
               else
                 { status: "skipped", message: "Unknown step type" }
               end

      step_execution.update!(
        status: :completed,
        completed_at: Time.current,
        output_data: result
      )

      result
    rescue StandardError => e
      step_execution.update!(
        status: :failed,
        completed_at: Time.current,
        error_message: e.message
      )
      raise
    end
  end

  private

  def execute_action(context)
    # Execute configured action
    { status: "completed", data: configuration }
  end

  def execute_decision(context)
    # Evaluate conditions and return next step
    conditions.each do |condition, next_step_id|
      return { next_step_id: next_step_id } if evaluate_condition(condition, context)
    end
    { next_step_id: next_step_id }
  end

  def execute_agent_task(context)
    # PROC-006: Integration with agents
    agent_type = configuration["agent_type"]
    agent = Agent.by_type(agent_type).available.first

    if agent
      task = agent.agent_tasks.create!(
        task_type: configuration["task_type"],
        input_data: context,
        priority: configuration["priority"] || 5
      )
      { task_id: task.id, status: "queued" }
    else
      { status: "error", message: "No available agent of type #{agent_type}" }
    end
  end

  def execute_integration(context)
    # Execute integration
    integration_id = configuration["integration_id"]
    integration = Integration.find(integration_id)
    integration.execute(configuration["operation"], context)
  end

  def execute_transform(context)
    # Transform data
    { transformed: true, data: context }
  end

  def execute_wait(context)
    # Wait for specified duration
    sleep(configuration["duration"] || 1)
    { waited: true }
  end

  def evaluate_condition(condition, context)
    # Simple condition evaluation
    # This should be extended with a proper expression evaluator
    true
  end
end
