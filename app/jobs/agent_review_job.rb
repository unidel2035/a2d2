# frozen_string_literal: true

# Agent Review Job - Performs peer review of completed tasks
class AgentReviewJob < ApplicationJob
  queue_as :default

  def perform(task_id, reviewer_agent_id, collaboration_id)
    task = AgentTask.find(task_id)
    reviewer = Agent.find(reviewer_agent_id)
    collaboration = AgentCollaboration.find(collaboration_id)

    # Execute review
    review_result = reviewer.execute(task)

    # Calculate quality score based on review
    quality_score = calculate_quality_score(review_result)

    # Add review to collaboration results
    consensus_results = collaboration.consensus_results || {}
    consensus_results[reviewer_agent_id.to_s] = {
      "agent_id" => reviewer_agent_id,
      "agent_name" => reviewer.name,
      "quality_score" => quality_score,
      "review_result" => review_result,
      "reviewed_at" => Time.current.to_s
    }

    collaboration.update!(consensus_results: consensus_results)

    # Add reviewer to task
    task.add_reviewer!(reviewer_agent_id)

    # Check if all reviews are complete
    if consensus_results.size >= collaboration.participating_agent_ids.size
      # Calculate consensus
      Orchestration::VerificationLayer.calculate_consensus(collaboration_id)
    end

    { task_id: task_id, reviewer_id: reviewer_agent_id, quality_score: quality_score }
  end

  private

  def calculate_quality_score(review_result)
    # Simple scoring based on review result
    return 100.0 if review_result.is_a?(Hash) && review_result[:valid] == true
    return 0.0 if review_result.is_a?(Hash) && review_result[:valid] == false

    # Default score
    70.0
  end
end
