# frozen_string_literal: true

module Orchestration
  # Consensus Mechanism - Multi-agent collaboration and decision making
  # Inspired by hive-mind's collaborative review patterns
  class ConsensusMechanism
    class << self
      # Create a consensus task requiring multiple agents
      def create_consensus_task(task_type:, input_data:, required_agents: 3, consensus_threshold: 0.7)
        # Create the main task
        task = AgentTask.create!(
          task_type: task_type,
          input_data: input_data,
          status: "pending",
          metadata: {
            requires_consensus: true,
            required_agents: required_agents,
            consensus_threshold: consensus_threshold
          }
        )

        # Create collaboration record
        collaboration = AgentCollaboration.create!(
          agent_task: task,
          primary_agent: nil,
          collaboration_type: "consensus",
          status: "pending",
          collaboration_metadata: {
            required_agents: required_agents,
            consensus_threshold: consensus_threshold
          }
        )

        log_event(
          type: "consensus_task_created",
          agent_task: task,
          severity: "info",
          message: "Consensus task created requiring #{required_agents} agents"
        )

        { task: task, collaboration: collaboration }
      end

      # Execute consensus task with multiple agents
      def execute_consensus_task(collaboration_id)
        collaboration = AgentCollaboration.find(collaboration_id)
        task = collaboration.agent_task

        required_agents = collaboration.collaboration_metadata["required_agents"] || 3

        # Select agents for consensus
        agents = select_consensus_agents(task, required_agents)

        if agents.size < required_agents
          collaboration.fail!("Insufficient available agents")
          return { success: false, reason: "insufficient_agents" }
        end

        collaboration.update!(
          participating_agent_ids: agents.map(&:id),
          status: "in_progress",
          started_at: Time.current
        )

        # Execute task with each agent
        results = agents.map do |agent|
          begin
            agent_result = execute_with_agent(task, agent)
            task.add_reviewer!(agent.id)

            {
              agent_id: agent.id,
              agent_name: agent.name,
              result: agent_result,
              success: true,
              timestamp: Time.current
            }
          rescue StandardError => e
            {
              agent_id: agent.id,
              agent_name: agent.name,
              error: e.message,
              success: false,
              timestamp: Time.current
            }
          end
        end

        # Calculate consensus
        consensus_result = calculate_consensus_result(results, collaboration)

        collaboration.complete!(consensus_result)

        log_event(
          type: "consensus_task_completed",
          agent_task: task,
          severity: "info",
          message: "Consensus task completed with #{results.count} agents",
          data: consensus_result
        )

        { success: true, results: results, consensus: consensus_result }
      end

      # Voting mechanism for decision making
      def conduct_vote(task_id, voting_agents: [], question: nil)
        task = AgentTask.find(task_id)

        votes = voting_agents.map do |agent|
          vote_result = agent.execute(task)

          {
            agent_id: agent.id,
            vote: extract_vote(vote_result),
            confidence: extract_confidence(vote_result),
            reasoning: extract_reasoning(vote_result)
          }
        end

        # Tally votes
        vote_tally = votes.group_by { |v| v[:vote] }
                          .transform_values(&:count)

        winner = vote_tally.max_by { |_vote, count| count }&.first
        total_votes = votes.count
        winner_count = vote_tally[winner] || 0

        consensus_reached = (winner_count.to_f / total_votes) >= 0.5

        result = {
          question: question,
          votes: votes,
          tally: vote_tally,
          winner: winner,
          consensus_reached: consensus_reached,
          confidence: calculate_average_confidence(votes)
        }

        log_event(
          type: "vote_conducted",
          agent_task: task,
          severity: "info",
          message: "Vote conducted with #{total_votes} agents, consensus: #{consensus_reached}",
          data: result
        )

        result
      end

      # Collaborative problem solving
      def collaborative_solve(task_id, collaboration_type: "assistance")
        task = AgentTask.find(task_id)
        primary_agent = task.agent

        # Get assisting agents
        assistants = select_assistant_agents(task, count: 2)

        collaboration = AgentCollaboration.create!(
          agent_task: task,
          primary_agent: primary_agent,
          collaboration_type: collaboration_type,
          participating_agent_ids: assistants.map(&:id),
          status: "in_progress",
          started_at: Time.current
        )

        # Primary agent works on task
        primary_result = primary_agent.execute(task)

        # Assistants provide suggestions
        assistant_suggestions = assistants.map do |assistant|
          {
            agent_id: assistant.id,
            suggestion: assistant.execute(task),
            timestamp: Time.current
          }
        end

        # Combine results
        combined_result = merge_collaborative_results(
          primary_result,
          assistant_suggestions
        )

        collaboration.complete!({
          primary_result: primary_result,
          assistant_suggestions: assistant_suggestions,
          combined_result: combined_result
        })

        log_event(
          type: "collaborative_solve_completed",
          agent: primary_agent,
          agent_task: task,
          severity: "info",
          message: "Collaborative problem solving completed with #{assistants.count} assistants"
        )

        combined_result
      end

      private

      def select_consensus_agents(task, count)
        # Select diverse, high-performing agents
        Agent.high_performers
             .select { |a| a.can_handle?(task.task_type) && a.can_accept_task? }
             .take(count)
      end

      def select_assistant_agents(task, count:)
        Agent.active
             .where.not(id: task.agent_id)
             .select { |a| a.can_handle?(task.task_type) }
             .take(count)
      end

      def execute_with_agent(task, agent)
        # Execute task with specific agent
        agent.execute(task)
      end

      def calculate_consensus_result(results, collaboration)
        successful_results = results.select { |r| r[:success] }

        return { consensus_reached: false, reason: "no_successful_results" } if successful_results.empty?

        # Compare results for similarity
        result_data = successful_results.map { |r| r[:result] }

        # Simple consensus: majority agreement
        result_groups = result_data.group_by(&:to_s)
        largest_group = result_groups.max_by { |_k, v| v.size }
        consensus_size = largest_group[1].size

        threshold = collaboration.collaboration_metadata["consensus_threshold"] || 0.7
        consensus_reached = (consensus_size.to_f / successful_results.size) >= threshold

        {
          consensus_reached: consensus_reached,
          consensus_result: largest_group[0],
          agreement_count: consensus_size,
          total_agents: results.size,
          successful_agents: successful_results.size,
          agreement_percentage: (consensus_size.to_f / successful_results.size * 100).round(2)
        }
      end

      def extract_vote(result)
        # Extract boolean vote from result
        return result[:vote] if result.is_a?(Hash) && result.key?(:vote)
        return result["vote"] if result.is_a?(Hash) && result.key?("vote")

        # Default interpretation
        result.present? ? "yes" : "no"
      end

      def extract_confidence(result)
        return result[:confidence] if result.is_a?(Hash) && result.key?(:confidence)
        return result["confidence"] if result.is_a?(Hash) && result.key?("confidence")
        0.5
      end

      def extract_reasoning(result)
        return result[:reasoning] if result.is_a?(Hash) && result.key?(:reasoning)
        return result["reasoning"] if result.is_a?(Hash) && result.key?("reasoning")
        nil
      end

      def calculate_average_confidence(votes)
        return 0.0 if votes.empty?

        total = votes.sum { |v| v[:confidence] || 0.5 }
        (total / votes.size).round(2)
      end

      def merge_collaborative_results(primary_result, suggestions)
        {
          primary: primary_result,
          suggestions: suggestions,
          merged_at: Time.current
        }
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
