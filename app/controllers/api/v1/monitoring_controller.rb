module Api
  module V1
    class MonitoringController < ApplicationController
      skip_before_action :verify_authenticity_token

      # GET /api/v1/monitoring/dashboard
      def dashboard
        orchestrator = Orchestrator.instance
        task_manager = TaskQueueManager.instance

        render json: {
          agents: orchestrator.monitor_agents,
          tasks: task_manager.queue_statistics,
          performance: orchestrator.get_performance_metrics,
          timestamp: Time.current
        }
      end

      # GET /api/v1/monitoring/agents/:id/metrics
      def agent_metrics
        agent = Agent.find(params[:id])
        verifier = VerificationLayer.instance

        render json: {
          agent: {
            id: agent.id,
            name: agent.name,
            status: agent.status,
            health_score: agent.health_score,
            current_load: agent.current_load
          },
          registry: agent.agent_registry_entry ? {
            consecutive_failures: agent.agent_registry_entry.consecutive_failures,
            last_health_check: agent.agent_registry_entry.last_health_check,
            performance_metrics: agent.agent_registry_entry.performance_metrics,
            success_rate: agent.agent_registry_entry.success_rate
          } : nil,
          quality: verifier.get_agent_quality_metrics(agent.id),
          recent_tasks: agent.agent_tasks.order(created_at: :desc).limit(10).map { |task|
            {
              id: task.id,
              type: task.task_type,
              status: task.status,
              created_at: task.created_at
            }
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Agent not found' }, status: :not_found
      end

      # GET /api/v1/monitoring/quality_report
      def quality_report
        verifier = VerificationLayer.instance
        time_range = params[:time_range]&.to_i&.hours || 24.hours

        report = verifier.generate_quality_report(
          agent_id: params[:agent_id],
          time_range: time_range
        )

        render json: report
      end

      # GET /api/v1/monitoring/memory_stats
      def memory_stats
        memory_manager = MemoryManager.instance

        stats = if params[:agent_id]
                  memory_manager.get_agent_memory_usage(params[:agent_id])
                else
                  memory_manager.get_memory_stats
                end

        render json: stats
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Agent not found' }, status: :not_found
      end

      # GET /api/v1/monitoring/health
      def health
        render json: {
          status: 'healthy',
          timestamp: Time.current,
          database: database_health,
          cache: cache_health,
          queue: queue_health
        }
      end

      private

      def database_health
        ActiveRecord::Base.connection.execute('SELECT 1')
        'ok'
      rescue StandardError
        'error'
      end

      def cache_health
        Rails.cache.write('health_check', true)
        Rails.cache.read('health_check') ? 'ok' : 'error'
      rescue StandardError
        'error'
      end

      def queue_health
        # Check if there are stuck jobs
        stuck_count = AgentTask.running.where('started_at < ?', 1.hour.ago).count
        stuck_count > 10 ? 'warning' : 'ok'
      rescue StandardError
        'error'
      end
    end
  end
end
