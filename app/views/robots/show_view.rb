# frozen_string_literal: true

module Robots
  class ShowView < ApplicationComponent
    def initialize(robot:, recent_tasks:, maintenance_records:, telemetry:)
      @robot = robot
      @recent_tasks = recent_tasks
      @maintenance_records = maintenance_records
      @telemetry = telemetry
    end

    def view_template
      div(class: "container mx-auto px-4 py-8") do
        render_back_link
        render_robot_header
        render_robot_details
        render_statistics
        render_recent_tasks
        render_maintenance_records
      end
    end

    private

    def render_back_link
      div(class: "mb-6") do
        a(
          href: helpers.robots_path,
          class: "text-blue-600 hover:text-blue-900"
        ) { "← Назад к списку роботов" }
      end
    end

    def render_robot_header
      div(class: "bg-white rounded-lg shadow mb-6") do
        div(class: "px-6 py-4 border-b border-gray-200 flex justify-between items-center") do
          div do
            h1(class: "text-2xl font-bold") { "Робот #{@robot.serial_number}" }
            p(class: "text-gray-500 mt-1") do
              "#{@robot.manufacturer} #{@robot.model}"
            end
          end

          div(class: "flex gap-3") do
            a(
              href: helpers.edit_robot_path(@robot),
              class: "px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
            ) { "Изменить" }

            a(
              href: helpers.new_robot_task_path(robot_id: @robot.id),
              class: "px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700"
            ) { "Создать задание" }

            a(
              href: helpers.new_robot_maintenance_record_path(robot_id: @robot.id),
              class: "px-4 py-2 bg-yellow-600 text-white rounded-md hover:bg-yellow-700"
            ) { "Запланировать ТО" }
          end
        end
      end
    end

    def render_robot_details
      div(class: "bg-white rounded-lg shadow mb-6") do
        div(class: "px-6 py-4 border-b border-gray-200") do
          h2(class: "text-xl font-semibold") { "Общая информация" }
        end

        div(class: "px-6 py-6") do
          div(class: "grid grid-cols-1 md:grid-cols-3 gap-6") do
            render_detail_field("Серийный номер", @robot.serial_number)
            render_detail_field("Производитель", @robot.manufacturer || "N/A")
            render_detail_field("Модель", @robot.model || "N/A")

            render_status_field

            render_detail_field(
              "Наработка (часов)",
              @robot.total_operation_hours ? @robot.total_operation_hours.round(1).to_s : "0"
            )

            render_detail_field(
              "Выполнено заданий",
              @robot.total_tasks&.to_s || "0"
            )

            render_detail_field(
              "Последнее ТО",
              @robot.last_maintenance_date ? @robot.last_maintenance_date.strftime("%d.%m.%Y") : "Не проводилось"
            )

            render_maintenance_due_field
          end
        end
      end
    end

    def render_detail_field(label, value)
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { label }
        p(class: "text-lg") { value }
      end
    end

    def render_status_field
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { "Статус" }
        status_class = case @robot.status
        when "active" then "bg-green-100 text-green-800"
        when "maintenance" then "bg-yellow-100 text-yellow-800"
        when "repair" then "bg-orange-100 text-orange-800"
        when "retired" then "bg-gray-100 text-gray-800"
        else "bg-gray-100 text-gray-800"
        end

        status_text = case @robot.status
        when "active" then "Активен"
        when "maintenance" then "На ТО"
        when "repair" then "В ремонте"
        when "retired" then "Списан"
        else @robot.status
        end

        span(class: "px-3 py-1 inline-flex text-sm font-semibold rounded-full #{status_class}") do
          status_text
        end
      end
    end

    def render_maintenance_due_field
      div do
        h3(class: "text-sm font-medium text-gray-500 mb-1") { "Требуется ТО" }
        if @robot.needs_maintenance?
          span(class: "px-3 py-1 inline-flex text-sm font-semibold rounded-full bg-red-100 text-red-800") do
            "Да (просрочено)"
          end
        elsif @robot.maintenance_due_date
          p(class: "text-lg") { "До #{@robot.maintenance_due_date.strftime('%d.%m.%Y')}" }
        else
          p(class: "text-lg") { "Нет" }
        end
      end
    end

    def render_statistics
      div(class: "bg-white rounded-lg shadow mb-6") do
        div(class: "px-6 py-4 border-b border-gray-200") do
          h2(class: "text-xl font-semibold") { "Статистика" }
        end

        div(class: "px-6 py-6") do
          div(class: "grid grid-cols-1 md:grid-cols-3 gap-6") do
            render_detail_field(
              "Коэффициент использования (30 дней)",
              "#{@robot.utilization_rate}%"
            )

            render_detail_field(
              "Средняя длительность задания",
              @robot.average_task_duration > 0 ? "#{@robot.average_task_duration.round(1)} мин" : "N/A"
            )

            render_detail_field(
              "Активных заданий",
              @robot.active_tasks.count.to_s
            )
          end
        end
      end
    end

    def render_recent_tasks
      div(class: "bg-white rounded-lg shadow mb-6") do
        div(class: "px-6 py-4 border-b border-gray-200 flex justify-between items-center") do
          h2(class: "text-xl font-semibold") { "Последние задания" }
          a(
            href: helpers.tasks_path(robot_id: @robot.id),
            class: "text-blue-600 hover:text-blue-900 text-sm"
          ) { "Посмотреть все →" }
        end

        if @recent_tasks.any?
          div(class: "overflow-x-auto") do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead(class: "bg-gray-50") do
                tr do
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Номер" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Статус" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Цель" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Плановая дата" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Длительность" }
                end
              end

              tbody(class: "bg-white divide-y divide-gray-200") do
                @recent_tasks.each do |task|
                  render_task_row(task)
                end
              end
            end
          end
        else
          div(class: "px-6 py-8 text-center text-gray-500") do
            "Нет заданий"
          end
        end
      end
    end

    def render_task_row(task)
      tr(class: "hover:bg-gray-50") do
        td(class: "px-6 py-4 whitespace-nowrap text-sm font-mono") do
          a(
            href: helpers.task_path(task),
            class: "text-blue-600 hover:text-blue-900"
          ) { task.task_number }
        end

        td(class: "px-6 py-4 whitespace-nowrap") do
          status_class = case task.status
          when "planned" then "bg-blue-100 text-blue-800"
          when "in_progress" then "bg-yellow-100 text-yellow-800"
          when "completed" then "bg-green-100 text-green-800"
          when "cancelled" then "bg-gray-100 text-gray-800"
          else "bg-gray-100 text-gray-800"
          end

          status_text = case task.status
          when "planned" then "Запланировано"
          when "in_progress" then "Выполняется"
          when "completed" then "Завершено"
          when "cancelled" then "Отменено"
          else task.status
          end

          span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_class}") do
            status_text
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm") { task.goal || "N/A" }

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
          task.planned_date ? task.planned_date.strftime("%d.%m.%Y %H:%M") : "N/A"
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
          task.duration ? "#{task.duration} мин" : "-"
        end
      end
    end

    def render_maintenance_records
      div(class: "bg-white rounded-lg shadow") do
        div(class: "px-6 py-4 border-b border-gray-200 flex justify-between items-center") do
          h2(class: "text-xl font-semibold") { "Техническое обслуживание" }
          a(
            href: helpers.maintenance_records_path(robot_id: @robot.id),
            class: "text-blue-600 hover:text-blue-900 text-sm"
          ) { "Посмотреть все →" }
        end

        if @maintenance_records.any?
          div(class: "overflow-x-auto") do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead(class: "bg-gray-50") do
                tr do
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Дата" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Тип" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Статус" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Техник" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Стоимость" }
                end
              end

              tbody(class: "bg-white divide-y divide-gray-200") do
                @maintenance_records.each do |record|
                  render_maintenance_row(record)
                end
              end
            end
          end
        else
          div(class: "px-6 py-8 text-center text-gray-500") do
            "Нет записей о ТО"
          end
        end
      end
    end

    def render_maintenance_row(record)
      tr(class: "hover:bg-gray-50") do
        td(class: "px-6 py-4 whitespace-nowrap text-sm") do
          record.scheduled_date.strftime("%d.%m.%Y")
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm") do
          type_text = case record.maintenance_type
          when "routine" then "Плановое"
          when "repair" then "Ремонт"
          when "component_replacement" then "Замена компонентов"
          else record.maintenance_type
          end
          type_text
        end

        td(class: "px-6 py-4 whitespace-nowrap") do
          status_class = case record.status
          when "scheduled" then "bg-blue-100 text-blue-800"
          when "in_progress" then "bg-yellow-100 text-yellow-800"
          when "completed" then "bg-green-100 text-green-800"
          when "cancelled" then "bg-gray-100 text-gray-800"
          else "bg-gray-100 text-gray-800"
          end

          status_text = case record.status
          when "scheduled" then "Запланировано"
          when "in_progress" then "Выполняется"
          when "completed" then "Завершено"
          when "cancelled" then "Отменено"
          else record.status
          end

          span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_class}") do
            status_text
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm") do
          record.technician ? record.technician.email : "Не назначен"
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm") do
          record.cost ? "#{record.cost} руб." : "-"
        end
      end
    end
  end
end
