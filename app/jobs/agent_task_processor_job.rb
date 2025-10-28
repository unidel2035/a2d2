class AgentTaskProcessorJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(task_id)
    task = AgentTask.find(task_id)

    unless task.assigned?
      Rails.logger.warn "Task #{task_id} is not assigned, current status: #{task.status}"
      return
    end

    # Start the task
    task.start!
    Rails.logger.info "Processing task #{task_id} with agent #{task.agent.name}"

    begin
      # Simulate task processing (in real implementation, this would call the agent's endpoint)
      result = process_task(task)

      # Complete the task with result
      task.complete!(result)
      Rails.logger.info "Task #{task_id} completed successfully"

      # Verify the result
      VerificationJob.perform_later(task.id)

    rescue StandardError => e
      Rails.logger.error "Task #{task_id} failed: #{e.message}"
      task.fail!(e.message)

      # Retry if possible
      if task.can_retry?
        task.retry!
        TaskDistributionJob.perform_later(task.id)
      else
        task.move_to_dead_letter!
      end
    end
  end

  private

  def process_task(task)
    # In a real implementation, this would:
    # 1. Call the agent's endpoint with the task payload
    # 2. Wait for the response
    # 3. Return the result
    #
    # For now, we'll simulate processing based on task type

    case task.task_type
    when 'data_analysis'
      simulate_data_analysis(task)
    when 'data_transformation'
      simulate_data_transformation(task)
    when 'validation'
      simulate_validation(task)
    else
      simulate_generic_processing(task)
    end
  end

  def simulate_data_analysis(task)
    # Simulate analysis
    sleep(rand(0.1..0.5))  # Simulate processing time

    {
      status: 'completed',
      analysis: {
        records_processed: task.payload['record_count'] || 100,
        insights: ['Pattern detected', 'Anomaly found at record 42'],
        metrics: {
          average: 75.5,
          median: 72.0,
          std_dev: 12.3
        }
      },
      processed_at: Time.current.iso8601
    }
  end

  def simulate_data_transformation(task)
    sleep(rand(0.1..0.3))

    {
      status: 'completed',
      transformation: {
        records_transformed: task.payload['record_count'] || 50,
        format: task.payload['target_format'] || 'json',
        output_size: '1.5MB'
      },
      processed_at: Time.current.iso8601
    }
  end

  def simulate_validation(task)
    sleep(rand(0.1..0.2))

    {
      status: 'completed',
      validation: {
        records_validated: task.payload['record_count'] || 200,
        valid_records: 195,
        invalid_records: 5,
        validation_rules_applied: 10
      },
      processed_at: Time.current.iso8601
    }
  end

  def simulate_generic_processing(task)
    sleep(rand(0.1..0.3))

    {
      status: 'completed',
      message: "Task processed successfully",
      processed_at: Time.current.iso8601
    }
  end
end
