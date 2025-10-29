class RobotsController < ApplicationController
  before_action :set_robot, only: [:show, :edit, :update, :destroy]

  def index
    @robots = Robot.all.order(created_at: :desc)

    # Фильтрация по статусу
    if params[:status].present?
      @robots = @robots.where(status: params[:status])
    end

    # Фильтрация по производителю
    if params[:manufacturer].present?
      @robots = @robots.by_manufacturer(params[:manufacturer])
    end

    # Поиск по серийному номеру
    if params[:search].present?
      @robots = @robots.where("serial_number ILIKE ?", "%#{params[:search]}%")
    end

    stats = {
      total: Robot.count,
      active: Robot.active_robots.count,
      maintenance: Robot.where(status: :maintenance).count,
      repair: Robot.where(status: :repair).count,
      retired: Robot.where(status: :retired).count
    }

    manufacturers = Robot.distinct.pluck(:manufacturer).compact

    render Robots::IndexView.new(
      robots: @robots,
      stats: stats,
      manufacturers: manufacturers,
      current_status: params[:status],
      current_manufacturer: params[:manufacturer],
      search_query: params[:search]
    )
  end

  def show
    recent_tasks = @robot.robot_tasks.order(created_at: :desc).limit(10)
    maintenance_records = @robot.maintenance_records.order(scheduled_date: :desc).limit(5)
    telemetry = @robot.telemetry_data.order(recorded_at: :desc).limit(20)

    render Robots::ShowView.new(
      robot: @robot,
      recent_tasks: recent_tasks,
      maintenance_records: maintenance_records,
      telemetry: telemetry
    )
  end

  def new
    @robot = Robot.new
    render Robots::NewView.new(robot: @robot)
  end

  def create
    @robot = Robot.new(robot_params)
    @robot.status = :active

    if @robot.save
      redirect_to robots_path, notice: "Робот успешно зарегистрирован"
    else
      render Robots::NewView.new(robot: @robot)
    end
  end

  def edit
    render Robots::EditView.new(robot: @robot)
  end

  def update
    if @robot.update(robot_params)
      redirect_to robot_path(@robot), notice: "Робот успешно обновлен"
    else
      render Robots::EditView.new(robot: @robot)
    end
  end

  def destroy
    @robot.destroy
    redirect_to robots_path, notice: "Робот успешно удален"
  end

  private

  def set_robot
    @robot = Robot.find(params[:id])
  end

  def robot_params
    params.require(:robot).permit(
      :serial_number,
      :manufacturer,
      :model,
      :status,
      :last_maintenance_date,
      :total_operation_hours,
      :total_tasks
    )
  end
end
