module Api
  module V1
    class AgentsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_agent, only: [:show, :update, :destroy, :activate, :deactivate, :heartbeat]

      # GET /api/v1/agents
      def index
        @agents = Agent.all
        @agents = @agents.by_type(params[:type]) if params[:type].present?
        @agents = @agents.where(status: params[:status]) if params[:status].present?

        render json: {
          agents: @agents.map { |agent| agent_json(agent) },
          total: @agents.count
        }
      end

      # GET /api/v1/agents/:id
      def show
        render json: agent_json(@agent, detailed: true)
      end

      # POST /api/v1/agents
      def create
        orchestrator = Orchestrator.instance

        agent = orchestrator.register_agent(
          name: params[:name],
          agent_type: params[:agent_type],
          capabilities: params[:capabilities] || [],
          endpoint: params[:endpoint],
          metadata: params[:metadata] || {}
        )

        render json: agent_json(agent), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # PATCH /api/v1/agents/:id
      def update
        if @agent.update(agent_params)
          render json: agent_json(@agent)
        else
          render json: { errors: @agent.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/agents/:id
      def destroy
        orchestrator = Orchestrator.instance
        orchestrator.deregister_agent(@agent.id)

        render json: { message: 'Agent deregistered successfully' }
      end

      # POST /api/v1/agents/:id/activate
      def activate
        orchestrator = Orchestrator.instance
        agent = orchestrator.activate_agent(@agent.id)

        render json: agent_json(agent)
      end

      # POST /api/v1/agents/:id/deactivate
      def deactivate
        orchestrator = Orchestrator.instance
        agent = orchestrator.deactivate_agent(@agent.id)

        render json: agent_json(agent)
      end

      # POST /api/v1/agents/:id/heartbeat
      def heartbeat
        @agent.heartbeat!

        render json: {
          agent_id: @agent.id,
          status: @agent.status,
          last_heartbeat: @agent.last_heartbeat,
          health_score: @agent.health_score
        }
      end

      # GET /api/v1/agents/stats
      def stats
        orchestrator = Orchestrator.instance
        stats = orchestrator.monitor_agents

        render json: stats
      end

      private

      def set_agent
        @agent = Agent.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Agent not found' }, status: :not_found
      end

      def agent_params
        params.permit(:name, :agent_type, :status, :endpoint, :version, :priority, :health_score,
                      capabilities: [], metadata: {})
      end

      def agent_json(agent, detailed: false)
        base = {
          id: agent.id,
          name: agent.name,
          agent_type: agent.agent_type,
          status: agent.status,
          capabilities: agent.capabilities,
          health_score: agent.health_score,
          last_heartbeat: agent.last_heartbeat
        }

        if detailed
          base.merge!(
            endpoint: agent.endpoint,
            version: agent.version,
            priority: agent.priority,
            metadata: agent.metadata,
            current_load: agent.current_load,
            created_at: agent.created_at,
            updated_at: agent.updated_at,
            registry_entry: agent.agent_registry_entry ? {
              registration_status: agent.agent_registry_entry.registration_status,
              consecutive_failures: agent.agent_registry_entry.consecutive_failures,
              last_health_check: agent.agent_registry_entry.last_health_check
            } : nil
          )
        end

        base
      end
    end
  end
end
