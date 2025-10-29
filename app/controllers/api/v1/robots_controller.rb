module Api
  module V1
    class RobotsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_robot, only: [:show, :update, :destroy]

      # GET /api/v1/robots
      def index
        @robots = Robot.all
        @robots = @robots.where(status: params[:status]) if params[:status].present?
        @robots = @robots.by_manufacturer(params[:manufacturer]) if params[:manufacturer].present?

        page = params[:page] || 1
        per_page = params[:per_page] || 25

        @robots = @robots.limit(per_page).offset((page.to_i - 1) * per_page.to_i)

        render json: {
          robots: @robots.map { |robot| robot_json(robot) },
          page: page.to_i,
          per_page: per_page.to_i,
          total: Robot.count
        }
      end

      # GET /api/v1/robots/:id
      def show
        render json: robot_json(@robot, detailed: true)
      end

      # POST /api/v1/robots
      def create
        @robot = Robot.register(robot_params.to_h)
        render json: robot_json(@robot), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # PATCH /api/v1/robots/:id
      def update
        if @robot.update(robot_params)
          render json: robot_json(@robot)
        else
          render json: { errors: @robot.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/robots/:id
      def destroy
        @robot.destroy
        render json: { message: 'Robot deleted successfully' }
      end

      private

      def set_robot
        @robot = Robot.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Robot not found' }, status: :not_found
      end

      def robot_params
        params.permit(
          :serial_number,
          :model,
          :manufacturer,
          :manufacture_date,
          :status,
          :last_maintenance_date,
          :total_operation_hours,
          :location,
          :description,
          :specifications
        )
      end

      def robot_json(robot, detailed: false)
        base = {
          id: robot.id,
          serial_number: robot.serial_number,
          model: robot.model,
          manufacturer: robot.manufacturer,
          status: robot.status,
          location: robot.location,
          total_operation_hours: robot.total_operation_hours
        }

        if detailed
          base.merge!(
            manufacture_date: robot.manufacture_date,
            last_maintenance_date: robot.last_maintenance_date,
            description: robot.description,
            specifications: robot.specifications,
            needs_maintenance: robot.needs_maintenance?,
            maintenance_due_date: robot.maintenance_due_date,
            utilization_rate: robot.utilization_rate,
            average_task_duration: robot.average_task_duration,
            active_tasks_count: robot.active_tasks.count,
            created_at: robot.created_at,
            updated_at: robot.updated_at
          )
        end

        base
      end
    end
  end
end
