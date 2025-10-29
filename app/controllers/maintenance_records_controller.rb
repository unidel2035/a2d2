class MaintenanceRecordsController < ApplicationController
  before_action :set_robot, only: [:new, :create]
  before_action :set_maintenance_record, only: [:show, :edit, :update, :destroy, :start, :complete, :cancel]

  def index
    @maintenance_records = MaintenanceRecord.includes(:robot, :technician).order(scheduled_date: :desc)

    # Фильтрация по статусу
    if params[:status].present?
      @maintenance_records = @maintenance_records.where(status: params[:status])
    end

    # Фильтрация по типу ТО
    if params[:maintenance_type].present?
      @maintenance_records = @maintenance_records.where(maintenance_type: params[:maintenance_type])
    end

    # Фильтрация по роботу
    if params[:robot_id].present?
      @maintenance_records = @maintenance_records.where(robot_id: params[:robot_id])
    end

    # Предстоящие ТО
    if params[:upcoming].present?
      @maintenance_records = @maintenance_records.upcoming
    end

    # Просроченные ТО
    if params[:overdue].present?
      @maintenance_records = @maintenance_records.overdue
    end

    stats = {
      total: MaintenanceRecord.count,
      scheduled: MaintenanceRecord.where(status: :scheduled).count,
      in_progress: MaintenanceRecord.where(status: :in_progress).count,
      completed: MaintenanceRecord.where(status: :completed).count,
      overdue: MaintenanceRecord.overdue.count,
      upcoming_week: MaintenanceRecord.upcoming.where("scheduled_date <= ?", 7.days.from_now).count
    }

    robots = Robot.all.order(:serial_number)

    render MaintenanceRecords::IndexView.new(
      maintenance_records: @maintenance_records,
      stats: stats,
      robots: robots,
      current_status: params[:status],
      current_maintenance_type: params[:maintenance_type],
      current_robot_id: params[:robot_id]
    )
  end

  def show
    render MaintenanceRecords::ShowView.new(maintenance_record: @maintenance_record)
  end

  def new
    @maintenance_record = @robot.maintenance_records.build
    @maintenance_record.scheduled_date = Date.current
    render MaintenanceRecords::NewView.new(maintenance_record: @maintenance_record, robot: @robot)
  end

  def create
    @maintenance_record = @robot.maintenance_records.build(maintenance_record_params)
    @maintenance_record.status = :scheduled

    if @maintenance_record.save
      redirect_to maintenance_records_path, notice: "Запись ТО успешно создана"
    else
      render MaintenanceRecords::NewView.new(maintenance_record: @maintenance_record, robot: @robot)
    end
  end

  def edit
    render MaintenanceRecords::EditView.new(maintenance_record: @maintenance_record)
  end

  def update
    if @maintenance_record.update(maintenance_record_params)
      redirect_to maintenance_record_path(@maintenance_record), notice: "Запись ТО успешно обновлена"
    else
      render MaintenanceRecords::EditView.new(maintenance_record: @maintenance_record)
    end
  end

  def destroy
    @maintenance_record.destroy
    redirect_to maintenance_records_path, notice: "Запись ТО успешно удалена"
  end

  def start
    @maintenance_record.start!
    redirect_to maintenance_record_path(@maintenance_record), notice: "ТО начато"
  end

  def complete
    @maintenance_record.complete!(
      description: params[:description],
      cost: params[:cost],
      replaced_components: params[:replaced_components]&.split(',')&.map(&:strip) || []
    )
    redirect_to maintenance_record_path(@maintenance_record), notice: "ТО завершено"
  end

  def cancel
    @maintenance_record.cancel!
    redirect_to maintenance_record_path(@maintenance_record), notice: "ТО отменено"
  end

  private

  def set_robot
    @robot = Robot.find(params[:robot_id]) if params[:robot_id].present?
  end

  def set_maintenance_record
    @maintenance_record = MaintenanceRecord.find(params[:id])
  end

  def maintenance_record_params
    params.require(:maintenance_record).permit(
      :scheduled_date,
      :maintenance_type,
      :technician_id,
      :description,
      :cost,
      :operation_hours_at_maintenance,
      replaced_components: []
    )
  end
end
