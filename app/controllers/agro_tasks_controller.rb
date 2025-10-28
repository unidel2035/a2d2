# Controller for managing agricultural tasks
class AgroTasksController < ApplicationController
  before_action :set_task, only: [:show, :retry]

  def index
    @tasks = AgroTask.includes(:agro_agent).order(created_at: :desc)
    @tasks = @tasks.where(status: params[:status]) if params[:status].present?
    @tasks = @tasks.where(agro_agent_id: params[:agent_id]) if params[:agent_id].present?
    @tasks = @tasks.page(params[:page]).per(50) if defined?(Kaminari)
  end

  def show
    @agent = @task.agro_agent
  end

  def new
    @task = AgroTask.new
    @agents = AgroAgent.active
  end

  def create
    orchestrator = AgroOrchestrator.new
    result = orchestrator.assign_task(
      task_params[:task_type],
      task_params[:input_data] || {},
      priority: task_params[:priority] || 'normal'
    )

    if result[:success]
      @task = AgroTask.find(result[:task_id])
      redirect_to @task, notice: 'Задача успешно создана и назначена агенту'
    else
      flash.now[:alert] = result[:error]
      @task = AgroTask.new
      @agents = AgroAgent.active
      render :new, status: :unprocessable_entity
    end
  end

  def retry
    if @task.can_retry?
      @task.update(status: 'pending', retry_count: @task.retry_count + 1)
      AgroTaskExecutionJob.perform_later(@task.id)
      redirect_to @task, notice: 'Задача отправлена на повторное выполнение'
    else
      redirect_to @task, alert: 'Невозможно повторить задачу'
    end
  end

  private

  def set_task
    @task = AgroTask.find(params[:id])
  end

  def task_params
    params.require(:agro_task).permit(:task_type, :priority, :input_data)
  end
end
