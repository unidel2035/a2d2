module Api
  module V1
    class MaintenanceRecordsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_maintenance_record, only: [:show, :update, :destroy]

      # GET /api/v1/maintenance_records
      def index
        @maintenance_records = MaintenanceRecord.all
        @maintenance_records = @maintenance_records.where(robot_id: params[:robot_id]) if params[:robot_id].present?
        @maintenance_records = @maintenance_records.where(status: params[:status]) if params[:status].present?
        @maintenance_records = @maintenance_records.where(maintenance_type: params[:maintenance_type]) if params[:maintenance_type].present?

        page = params[:page] || 1
        per_page = params[:per_page] || 25

        @maintenance_records = @maintenance_records.limit(per_page).offset((page.to_i - 1) * per_page.to_i)

        render json: {
          maintenance_records: @maintenance_records.map { |record| maintenance_record_json(record) },
          page: page.to_i,
          per_page: per_page.to_i,
          total: MaintenanceRecord.count
        }
      end

      # GET /api/v1/maintenance_records/:id
      def show
        render json: maintenance_record_json(@maintenance_record, detailed: true)
      end

      # POST /api/v1/maintenance_records
      def create
        @maintenance_record = MaintenanceRecord.new(maintenance_record_params)

        if @maintenance_record.save
          render json: maintenance_record_json(@maintenance_record), status: :created
        else
          render json: { errors: @maintenance_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/maintenance_records/:id
      def update
        if @maintenance_record.update(maintenance_record_params)
          render json: maintenance_record_json(@maintenance_record)
        else
          render json: { errors: @maintenance_record.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/maintenance_records/:id
      def destroy
        @maintenance_record.destroy
        render json: { message: 'Maintenance record deleted successfully' }
      end

      private

      def set_maintenance_record
        @maintenance_record = MaintenanceRecord.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Maintenance record not found' }, status: :not_found
      end

      def maintenance_record_params
        params.permit(
          :robot_id,
          :technician_id,
          :scheduled_date,
          :completed_date,
          :maintenance_type,
          :status,
          :description,
          :cost,
          :next_maintenance_date,
          :operation_hours_at_maintenance,
          replaced_components: []
        )
      end

      def maintenance_record_json(record, detailed: false)
        base = {
          id: record.id,
          robot_id: record.robot_id,
          scheduled_date: record.scheduled_date,
          maintenance_type: record.maintenance_type,
          status: record.status
        }

        if detailed
          base.merge!(
            technician_id: record.technician_id,
            completed_date: record.completed_date,
            description: record.description,
            cost: record.cost,
            next_maintenance_date: record.next_maintenance_date,
            operation_hours_at_maintenance: record.operation_hours_at_maintenance,
            replaced_components: record.replaced_components,
            overdue: record.overdue?,
            created_at: record.created_at,
            updated_at: record.updated_at
          )
        end

        base
      end
    end
  end
end
