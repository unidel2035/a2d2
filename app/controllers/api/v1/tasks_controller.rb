module Api
  module V1
    class TasksController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_task, only: [:show, :retry_task, :cancel]

      # GET /api/v1/tasks
      def index
        @tasks = AgentTask.all
        @tasks = @tasks.where(status: params[:status]) if params[:status].present?
        @tasks = @tasks.where(task_type: params[:task_type]) if params[:task_type].present?
        @tasks = @tasks.where(agent_id: params[:agent_id]) if params[:agent_id].present?
        @tasks = @tasks.by_priority

        page = params[:page] || 1
        per_page = params[:per_page] || 25

        @tasks = @tasks.limit(per_page).offset((page.to_i - 1) * per_page.to_i)

        render json: {
          tasks: @tasks.map { |task| task_json(task) },
          page: page.to_i,
          per_page: per_page.to_i,
          total: AgentTask.count
        }
      end

      # GET /api/v1/tasks/:id
      def show
        render json: task_json(@task, detailed: true)
      end

      # POST /api/v1/tasks
      def create
        task_manager = TaskQueueManager.instance

        task = task_manager.enqueue_task(
          task_type: params[:task_type],
          payload: params[:payload] || {},
          priority: params[:priority] || 0,
          deadline: params[:deadline],
          required_capability: params[:required_capability],
          metadata: params[:metadata] || {},
          parent_task_id: params[:parent_task_id]
        )

        render json: task_json(task), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/tasks/batch
      def batch_create
        task_manager = TaskQueueManager.instance

        tasks = task_manager.enqueue_batch(params[:tasks] || [])

        render json: {
          tasks: tasks.map { |task| task_json(task) },
          count: tasks.size
        }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # POST /api/v1/tasks/:id/retry
      def retry_task
        if @task.retry!
          TaskDistributionJob.perform_later(@task.id)
          render json: task_json(@task)
        else
          render json: { error: 'Task cannot be retried' }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/tasks/:id/cancel
      def cancel
        if @task.pending? || @task.assigned?
          @task.update!(status: 'failed', error_message: 'Cancelled by user')
          render json: task_json(@task)
        else
          render json: { error: 'Task cannot be cancelled' }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/tasks/stats
      def stats
        task_manager = TaskQueueManager.instance
        stats = task_manager.queue_statistics

        render json: stats
      end

      # GET /api/v1/tasks/dead_letter
      def dead_letter
        task_manager = TaskQueueManager.instance
        stats = task_manager.process_dead_letter_queue

        render json: stats
      end

      private

      def set_task
        @task = AgentTask.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Task not found' }, status: :not_found
      end

      def task_json(task, detailed: false)
        base = {
          id: task.id,
          task_type: task.task_type,
          status: task.status,
          priority: task.priority,
          agent_id: task.agent_id,
          created_at: task.created_at,
          deadline: task.deadline
        }

        if detailed
          base.merge!(
            payload: task.payload,
            result: task.result,
            metadata: task.metadata,
            parent_task_id: task.parent_task_id,
            started_at: task.started_at,
            completed_at: task.completed_at,
            retry_count: task.retry_count,
            max_retries: task.max_retries,
            error_message: task.error_message,
            required_capability: task.required_capability,
            duration: task.duration,
            updated_at: task.updated_at
          )
        end

        base
      end
    end
  end
end
