class VerificationJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    task = AgentTask.find(task_id)

    unless task.completed?
      Rails.logger.warn "Cannot verify task #{task_id}: not completed"
      return
    end

    verifier = VerificationLayer.instance

    # Determine which verification types to run based on task metadata
    verification_types = task.metadata.dig('verification', 'types') || [:schema, :completeness]

    result = verifier.verify_task_result(task_id, verification_types: verification_types)

    Rails.logger.info "Verification completed for task #{task_id}: score #{result[:overall_score]}"

    # Update task metadata with verification result
    task.update!(
      metadata: task.metadata.merge(
        verification_result: result
      )
    )
  end
end
