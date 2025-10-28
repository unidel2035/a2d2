# frozen_string_literal: true

# WorkflowsController handles REST API for n8n-compatible workflows
class WorkflowsController < ApplicationController
  before_action :set_workflow, only: [:show, :update, :destroy, :execute, :activate, :deactivate]

  # GET /workflows
  def index
    @workflows = Workflow.all.order(created_at: :desc)

    render json: {
      workflows: @workflows.map(&:to_n8n_format),
      total: @workflows.count
    }
  end

  # GET /workflows/:id
  def show
    render json: @workflow.to_n8n_format
  end

  # POST /workflows
  def create
    if params[:n8n_data]
      # Import from n8n format
      service = N8nIntegrationService.new
      validation = service.validate_n8n_workflow(workflow_params[:n8n_data])

      unless validation[:valid]
        return render json: {
          error: 'Invalid n8n workflow',
          errors: validation[:errors]
        }, status: :unprocessable_entity
      end

      @workflow = service.import_workflow(
        workflow_params[:n8n_data],
        user: current_user
      )
    else
      # Create directly
      @workflow = Workflow.new(workflow_params.except(:n8n_data))
      @workflow.user = current_user

      unless @workflow.save
        return render json: {
          error: 'Failed to create workflow',
          errors: @workflow.errors.full_messages
        }, status: :unprocessable_entity
      end
    end

    render json: @workflow.to_n8n_format, status: :created
  end

  # PATCH/PUT /workflows/:id
  def update
    if @workflow.update(workflow_params.except(:n8n_data))
      render json: @workflow.to_n8n_format
    else
      render json: {
        error: 'Failed to update workflow',
        errors: @workflow.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # DELETE /workflows/:id
  def destroy
    @workflow.destroy
    head :no_content
  end

  # POST /workflows/:id/execute
  def execute
    execution = @workflow.execute(
      input_data: execution_params[:input_data] || {},
      execution_mode: execution_params[:mode] || 'manual'
    )

    render json: {
      execution_id: execution.id,
      status: execution.status,
      started_at: execution.started_at
    }
  end

  # POST /workflows/:id/activate
  def activate
    if @workflow.update(status: 'active')
      render json: {
        message: 'Workflow activated',
        workflow: @workflow.to_n8n_format
      }
    else
      render json: {
        error: 'Failed to activate workflow',
        errors: @workflow.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # POST /workflows/:id/deactivate
  def deactivate
    if @workflow.update(status: 'inactive')
      render json: {
        message: 'Workflow deactivated',
        workflow: @workflow.to_n8n_format
      }
    else
      render json: {
        error: 'Failed to deactivate workflow',
        errors: @workflow.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  # GET /workflows/templates
  def templates
    templates = [
      { type: 'simple_http', name: 'Simple HTTP Request' },
      { type: 'ai_agent_pipeline', name: 'AI Agent Pipeline' },
      { type: 'data_transformation', name: 'Data Transformation' }
    ]

    render json: { templates: templates }
  end

  # POST /workflows/from_template
  def from_template
    template_type = params[:template_type]

    begin
      template_data = N8nIntegrationService.create_template(template_type)
      service = N8nIntegrationService.new
      @workflow = service.import_workflow(template_data, user: current_user)

      render json: @workflow.to_n8n_format, status: :created
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  private

  def set_workflow
    @workflow = Workflow.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Workflow not found' }, status: :not_found
  end

  def workflow_params
    params.require(:workflow).permit(
      :name,
      :status,
      :n8n_data,
      settings: {},
      static_data: {},
      tags: []
    )
  end

  def execution_params
    params.permit(:mode, input_data: {})
  end

  def current_user
    # Placeholder - implement your authentication
    User.first
  end
end
