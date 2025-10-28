# frozen_string_literal: true

module WorkflowNodeHandlers
  # Handler for trigger nodes - entry points of workflows
  class TriggerHandler < BaseHandler
    def execute(input_data, parameters, execution_context)
      {
        data: input_data,
        output: input_data,
        triggered_at: Time.current,
        trigger_type: parameters['triggerType'] || 'manual'
      }
    end
  end
end
