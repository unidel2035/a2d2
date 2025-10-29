class TasksController < ApplicationController
  before_action :set_robot, only: [:new, :create]
  before_action :set_task, only: [:show, :edit, :update, :destroy, :start, :complete, :cancel]

  def index
    @tasks = RobotTask.includes(:robot, :operator).order(created_at: :desc)

    # Фильтрация по статусу
    if params[:status].present?
      @tasks = @tasks.where(status: params[:status])
    end

    # Фильтрация по роботу
    if params[:robot_id].present?
      @tasks = @tasks.where(robot_id: params[:robot_id])
    end

    # Предстоящие задания
    if params[:upcoming].present?
      @tasks = @tasks.upcoming
    end

    # Просроченные задания
    if params[:overdue].present?
      @tasks = @tasks.overdue
    end

    stats = {
      total: RobotTask.count,
      planned: RobotTask.where(status: :planned).count,
      in_progress: RobotTask.where(status: :in_progress).count,
      completed: RobotTask.where(status: :completed).count,
      cancelled: RobotTask.where(status: :cancelled).count,
      overdue: RobotTask.overdue.count
    }

    robots = Robot.all.order(:serial_number)

    render Tasks::IndexView.new(
      tasks: @tasks,
      stats: stats,
      robots: robots,
      current_status: params[:status],
      current_robot_id: params[:robot_id]
    )
  end

  def show
    render Tasks::ShowView.new(task: @task)
  end

  def new
    @task = @robot.robot_tasks.build
    render Tasks::NewView.new(task: @task, robot: @robot)
  end

  def create
    @task = @robot.robot_tasks.build(task_params)
    @task.status = :planned

    if @task.save
      redirect_to tasks_path, notice: "Задание успешно создано"
    else
      render Tasks::NewView.new(task: @task, robot: @robot)
    end
  end

  def edit
    render Tasks::EditView.new(task: @task)
  end

  def update
    if @task.update(task_params)
      redirect_to task_path(@task), notice: "Задание успешно обновлено"
    else
      render Tasks::EditView.new(task: @task)
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Задание успешно удалено"
  end

  def start
    @task.start!
    redirect_to task_path(@task), notice: "Задание запущено"
  end

  def complete
    @task.complete!
    redirect_to task_path(@task), notice: "Задание завершено"
  end

  def cancel
    @task.cancel!
    redirect_to task_path(@task), notice: "Задание отменено"
  end

  private

  def set_robot
    @robot = Robot.find(params[:robot_id]) if params[:robot_id].present?
  end

  def set_task
    @task = RobotTask.find(params[:id])
  end

  def task_params
    params.require(:robot_task).permit(
      :operator_id,
      :planned_date,
      :goal,
      :location,
      :latitude,
      :longitude,
      :altitude,
      :parameters
    )
  end
end
