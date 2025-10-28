# PROC-001: Visual drag-and-drop process builder support
# This service provides the backend logic for the process builder
class ProcessBuilderService
  def initialize(process)
    @process = process
  end

  # PROC-002: Library of ready-made blocks
  def self.available_blocks
    {
      actions: [
        {
          type: "action",
          name: "Send Email",
          icon: "envelope",
          config_schema: {
            to: "string",
            subject: "string",
            body: "text"
          }
        },
        {
          type: "action",
          name: "Create Record",
          icon: "plus-circle",
          config_schema: {
            model: "string",
            attributes: "object"
          }
        },
        {
          type: "action",
          name: "Update Record",
          icon: "edit",
          config_schema: {
            model: "string",
            id: "string",
            attributes: "object"
          }
        }
      ],
      decisions: [
        {
          type: "decision",
          name: "If/Else",
          icon: "code-branch",
          config_schema: {
            condition: "string",
            true_branch: "step_id",
            false_branch: "step_id"
          }
        },
        {
          type: "decision",
          name: "Switch/Case",
          icon: "list",
          config_schema: {
            variable: "string",
            cases: "array"
          }
        }
      ],
      agents: [
        {
          type: "agent_task",
          name: "Analyze Data",
          icon: "chart-bar",
          agent_type: "Agents::AnalyzerAgent",
          config_schema: {
            data: "object",
            analysis_type: "string"
          }
        },
        {
          type: "agent_task",
          name: "Transform Data",
          icon: "exchange-alt",
          agent_type: "Agents::TransformerAgent",
          config_schema: {
            input_data: "object",
            transformation: "string"
          }
        },
        {
          type: "agent_task",
          name: "Validate Data",
          icon: "check-circle",
          agent_type: "Agents::ValidatorAgent",
          config_schema: {
            data: "object",
            rules: "array"
          }
        },
        {
          type: "agent_task",
          name: "Generate Report",
          icon: "file-alt",
          agent_type: "Agents::ReporterAgent",
          config_schema: {
            data: "object",
            format: "string"
          }
        }
      ],
      integrations: [
        {
          type: "integration",
          name: "Call API",
          icon: "cloud",
          config_schema: {
            integration_id: "string",
            operation: "string",
            data: "object"
          }
        },
        {
          type: "integration",
          name: "Webhook",
          icon: "rss",
          config_schema: {
            url: "string",
            method: "string",
            headers: "object",
            body: "object"
          }
        }
      ],
      control: [
        {
          type: "wait",
          name: "Wait",
          icon: "clock",
          config_schema: {
            duration: "number"
          }
        },
        {
          type: "parallel",
          name: "Parallel Execution",
          icon: "stream",
          config_schema: {
            branches: "array"
          }
        },
        {
          type: "loop",
          name: "Loop",
          icon: "redo",
          config_schema: {
            collection: "array",
            step_id: "string"
          }
        }
      ]
    }
  end

  def add_step(step_params)
    order = @process.process_steps.maximum(:order).to_i + 1

    @process.process_steps.create!(
      name: step_params[:name],
      description: step_params[:description],
      step_type: step_params[:step_type],
      order: order,
      configuration: step_params[:configuration] || {},
      input_schema: step_params[:input_schema] || {},
      output_schema: step_params[:output_schema] || {},
      conditions: step_params[:conditions] || {}
    )
  end

  def remove_step(step_id)
    step = @process.process_steps.find(step_id)
    step.destroy!
    reorder_steps
  end

  def reorder_steps
    @process.process_steps.order(:order).each_with_index do |step, index|
      step.update!(order: index + 1)
    end
  end

  def validate_process
    errors = []

    # Check if process has at least one step
    if @process.process_steps.empty?
      errors << "Process must have at least one step"
    end

    # Check for unreachable steps
    reachable_steps = find_reachable_steps
    @process.process_steps.each do |step|
      unless reachable_steps.include?(step.id)
        errors << "Step '#{step.name}' is unreachable"
      end
    end

    # Validate each step configuration
    @process.process_steps.each do |step|
      step_errors = validate_step_configuration(step)
      errors.concat(step_errors)
    end

    {
      valid: errors.empty?,
      errors: errors
    }
  end

  private

  def find_reachable_steps
    return [] if @process.process_steps.empty?

    reachable = Set.new
    queue = [@process.process_steps.order(:order).first.id]

    while queue.any?
      step_id = queue.shift
      next if reachable.include?(step_id)

      reachable.add(step_id)
      step = @process.process_steps.find(step_id)

      # Add next steps
      queue << step.next_step_id if step.next_step_id

      # Add conditional branches
      if step.conditions.is_a?(Hash)
        step.conditions.values.each do |next_id|
          queue << next_id if next_id
        end
      end
    end

    reachable.to_a
  end

  def validate_step_configuration(step)
    errors = []

    # Validate based on step type
    case step.step_type
    when "agent_task"
      if step.configuration["agent_type"].blank?
        errors << "Step '#{step.name}': agent_type is required"
      end
    when "integration"
      if step.configuration["integration_id"].blank?
        errors << "Step '#{step.name}': integration_id is required"
      end
    when "decision"
      if step.conditions.blank?
        errors << "Step '#{step.name}': conditions are required for decision steps"
      end
    end

    errors
  end
end
