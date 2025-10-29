# frozen_string_literal: true

module Orchestration
  # Verification Layer - Ensures quality of agent work output
  # Implements verification patterns similar to hive-mind's review system
  class VerificationLayer
    class << self
      # Verify a completed task
      def verify_task(task_id, verifier_agent_id: nil)
        task = AgentTask.find(task_id)

        unless task.completed?
          return { verified: false, reason: "task_not_completed" }
        end

        verifier = verifier_agent_id ? Agent.find(verifier_agent_id) : select_verifier(task)

        # Perform verification checks
        verification_result = perform_verification(task, verifier)

        if verification_result[:passed]
          task.mark_verified!(verification_result[:quality_score], verification_result[:details])
          task.agent&.task_completed!(task.processing_time.to_i) if task.agent

          log_event(
            type: "task_verified",
            agent: verifier,
            agent_task: task,
            severity: "info",
            message: "Task #{task_id} verified successfully with score #{verification_result[:quality_score]}"
          )
        else
          task.mark_verification_failed!(verification_result[:reason])

          # Retry if verification failed
          if task.retry_count < task.max_retries
            task.retry!

            log_event(
              type: "task_verification_failed_retry",
              agent: task.agent,
              agent_task: task,
              severity: "warning",
              message: "Task #{task_id} verification failed, retrying"
            )
          else
            log_event(
              type: "task_verification_failed_final",
              agent: task.agent,
              agent_task: task,
              severity: "error",
              message: "Task #{task_id} verification failed, max retries reached"
            )
          end
        end

        verification_result
      end

      # Batch verify multiple tasks
      def batch_verify(task_ids)
        results = task_ids.map do |task_id|
          result = verify_task(task_id)
          { task_id: task_id, result: result }
        end

        {
          total: results.count,
          passed: results.count { |r| r[:result][:passed] },
          failed: results.count { |r| !r[:result][:passed] },
          results: results
        }
      end

      # Verify all pending tasks
      def verify_pending_tasks
        tasks = AgentTask.needs_verification

        log_event(
          type: "batch_verification_started",
          severity: "info",
          message: "Starting batch verification of #{tasks.count} tasks"
        )

        results = tasks.map { |task| verify_task(task.id) }

        {
          total: results.count,
          passed: results.count { |r| r[:passed] },
          failed: results.count { |r| !r[:passed] }
        }
      end

      # Request multi-agent review for complex tasks
      def request_peer_review(task_id, reviewer_count: 3)
        task = AgentTask.find(task_id)

        # Select multiple agents for review
        reviewers = select_peer_reviewers(task, count: reviewer_count)

        if reviewers.empty?
          return { success: false, reason: "no_available_reviewers" }
        end

        # Create collaboration for peer review
        collaboration = AgentCollaboration.create!(
          agent_task: task,
          primary_agent: task.agent,
          collaboration_type: "review",
          participating_agent_ids: reviewers.map(&:id),
          status: "pending"
        )

        # Schedule review jobs for each reviewer
        reviewers.each do |reviewer|
          AgentReviewJob.perform_later(task.id, reviewer.id, collaboration.id)
        end

        log_event(
          type: "peer_review_requested",
          agent_task: task,
          severity: "info",
          message: "Peer review requested for task #{task_id} with #{reviewers.count} reviewers",
          data: { reviewer_ids: reviewers.map(&:id) }
        )

        { success: true, collaboration: collaboration, reviewers: reviewers }
      end

      # Calculate consensus from multiple reviews
      def calculate_consensus(collaboration_id)
        collaboration = AgentCollaboration.find(collaboration_id)
        task = collaboration.agent_task

        # Get all reviews for this task
        reviews = collaboration.consensus_results || {}

        return { consensus_reached: false, reason: "insufficient_reviews" } if reviews.empty?

        # Calculate average scores and identify issues
        quality_scores = reviews.values.map { |r| r["quality_score"] }.compact
        avg_quality = quality_scores.sum / quality_scores.size.to_f

        # Check for consensus (e.g., scores within 20 points of each other)
        score_range = quality_scores.max - quality_scores.min
        consensus_reached = score_range <= 20.0

        result = {
          consensus_reached: consensus_reached,
          average_quality: avg_quality.round(2),
          score_range: score_range,
          review_count: reviews.size,
          individual_scores: quality_scores
        }

        if consensus_reached && avg_quality >= 70.0
          task.mark_verified!(avg_quality, result.merge(verified_by_consensus: true))

          log_event(
            type: "consensus_reached",
            agent_task: task,
            severity: "info",
            message: "Consensus reached for task #{task.id} with quality score #{avg_quality}"
          )
        else
          log_event(
            type: "consensus_failed",
            agent_task: task,
            severity: "warning",
            message: "Consensus not reached for task #{task.id}",
            data: result
          )
        end

        collaboration.complete!(result)
        result
      end

      private

      def perform_verification(task, verifier)
        # Basic verification checks
        checks = {
          has_output: task.output_data.present?,
          no_errors: task.error_message.blank?,
          completed_on_time: !task.overdue?,
          within_retry_limit: task.retry_count <= task.max_retries
        }

        # Calculate quality score
        passed_checks = checks.values.count(true)
        base_score = (passed_checks.to_f / checks.size * 100).round(2)

        # Additional quality checks based on output data
        output_quality_score = assess_output_quality(task)

        final_score = (base_score * 0.5) + (output_quality_score * 0.5)

        {
          passed: final_score >= 60.0,
          quality_score: final_score.round(2),
          checks: checks,
          output_quality: output_quality_score,
          verifier_id: verifier&.id,
          verified_at: Time.current,
          reason: final_score < 60.0 ? "quality_score_below_threshold" : nil,
          details: {
            checks: checks,
            base_score: base_score,
            output_quality_score: output_quality_score
          }
        }
      end

      def assess_output_quality(task)
        output = task.output_data

        return 0.0 if output.blank?

        score = 100.0

        # Check output structure
        if output.is_a?(Hash)
          score -= 10 if output.key?("error")
          score += 10 if output.key?("result") || output.key?("data")
        end

        # Check for common error indicators
        output_str = output.to_s.downcase
        score -= 20 if output_str.include?("error")
        score -= 20 if output_str.include?("failed")
        score -= 15 if output_str.include?("invalid")

        [score, 0.0].max
      end

      def select_verifier(task)
        # Select a different agent than the one who performed the task
        Agent.active
             .where.not(id: task.agent_id)
             .where(type: task.agent&.type)
             .order(success_rate: :desc)
             .first
      end

      def select_peer_reviewers(task, count: 3)
        # Select agents capable of reviewing this task type
        # Exclude the agent who performed the task
        Agent.active
             .where.not(id: task.agent_id)
             .select { |a| a.can_handle?(task.task_type) }
             .take(count)
      end

      def log_event(type:, agent: nil, agent_task: nil, severity: "info", message: nil, data: {})
        OrchestratorEvent.log(
          event_type: type,
          severity: severity,
          agent: agent,
          agent_task: agent_task,
          message: message,
          data: data
        )
      end
    end
  end
end
