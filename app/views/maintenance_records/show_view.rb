# frozen_string_literal: true

module MaintenanceRecords
  class ShowView < ApplicationComponent
    def initialize(maintenance_record:)
      @maintenance_record = maintenance_record
    end

    def view_template
      div(class: "container mx-auto px-4 py-8") do
        div(class: "mb-6") do
          a(
            href: maintenance_records_path,
            class: "text-blue-600 hover:text-blue-900"
          ) { "← Назад к списку ТО" }
        end

        div(class: "bg-white rounded-lg shadow") do
          div(class: "px-6 py-4 border-b border-gray-200") do
            h1(class: "text-2xl font-bold") { "Запись ТО ##{@maintenance_record.id}" }
          end

          div(class: "px-6 py-6") do
            div(class: "grid grid-cols-1 md:grid-cols-2 gap-6") do
              render_detail_field("Робот", @maintenance_record.robot.serial_number)
              render_detail_field("Статус", maintenance_status_text(@maintenance_record.status))
              render_detail_field("Тип ТО", maintenance_type_text(@maintenance_record.maintenance_type))
              render_detail_field(
                "Плановая дата",
                @maintenance_record.scheduled_date.strftime("%d.%m.%Y")
              )
              render_detail_field(
                "Техник",
                @maintenance_record.technician ? @maintenance_record.technician.email : "Не назначен"
              )
              render_detail_field(
                "Стоимость",
                @maintenance_record.cost ? "#{@maintenance_record.cost} руб." : "Не указана"
              )
            end

            if @maintenance_record.description.present?
              div(class: "mt-6") do
                h3(class: "text-sm font-medium text-gray-500 mb-2") { "Описание" }
                p(class: "text-lg") { @maintenance_record.description }
              end
            end
          end
        end
      end
    end

    private

    def render_detail_field(label, value)
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { label }
        p(class: "text-lg") { value }
      end
    end

    def maintenance_status_text(status)
      case status
      when "scheduled" then "Запланировано"
      when "in_progress" then "Выполняется"
      when "completed" then "Завершено"
      when "cancelled" then "Отменено"
      else status
      end
    end

    def maintenance_type_text(type)
      case type
      when "routine" then "Плановое"
      when "repair" then "Ремонт"
      when "component_replacement" then "Замена компонентов"
      else type
      end
    end
  end
end
