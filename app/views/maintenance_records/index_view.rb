# frozen_string_literal: true

module MaintenanceRecords
  class IndexView < ApplicationComponent
    def initialize(maintenance_records:, stats:, robots:, current_status: nil, current_maintenance_type: nil, current_robot_id: nil)
      @maintenance_records = maintenance_records
      @stats = stats
      @robots = robots
      @current_status = current_status
      @current_maintenance_type = current_maintenance_type
      @current_robot_id = current_robot_id
    end

    def view_template
      div(class: "container mx-auto px-4 py-8") do
        h1(class: "text-3xl font-bold mb-6") { "Техническое обслуживание" }

        render_stats_cards
        render_filters
        render_maintenance_records_table
      end
    end

    private

    def render_stats_cards
      div(class: "grid grid-cols-1 md:grid-cols-5 gap-4 mb-8") do
        render_stat_card("Всего записей", @stats[:total], "bg-white")
        render_stat_card("Запланировано", @stats[:scheduled], "bg-blue-50", "text-blue-600")
        render_stat_card("Выполняется", @stats[:in_progress], "bg-yellow-50", "text-yellow-600")
        render_stat_card("Завершено", @stats[:completed], "bg-green-50", "text-green-600")
        render_stat_card("Просрочено", @stats[:overdue], "bg-red-50", "text-red-600")
      end
    end

    def render_stat_card(title, value, bg_class, text_class = "")
      div(class: "#{bg_class} rounded-lg shadow p-6") do
        h3(class: "text-gray-500 text-sm font-medium") { title }
        p(class: "text-3xl font-bold #{text_class}") { value.to_s }
      end
    end

    def render_filters
      div(class: "bg-white rounded-lg shadow mb-6 p-6") do
        form(method: "get", action: helpers.maintenance_records_path, class: "grid grid-cols-1 md:grid-cols-4 gap-4") do
          # Фильтр по статусу
          div do
            label(class: "block text-sm font-medium text-gray-700 mb-2") { "Статус" }
            select(
              name: "status",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            ) do
              option(value: "", selected: @current_status.nil?) { "Все статусы" }
              option(value: "scheduled", selected: @current_status == "scheduled") { "Запланировано" }
              option(value: "in_progress", selected: @current_status == "in_progress") { "Выполняется" }
              option(value: "completed", selected: @current_status == "completed") { "Завершено" }
              option(value: "cancelled", selected: @current_status == "cancelled") { "Отменено" }
            end
          end

          # Фильтр по типу ТО
          div do
            label(class: "block text-sm font-medium text-gray-700 mb-2") { "Тип ТО" }
            select(
              name: "maintenance_type",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            ) do
              option(value: "", selected: @current_maintenance_type.nil?) { "Все типы" }
              option(value: "routine", selected: @current_maintenance_type == "routine") { "Плановое" }
              option(value: "repair", selected: @current_maintenance_type == "repair") { "Ремонт" }
              option(value: "component_replacement", selected: @current_maintenance_type == "component_replacement") { "Замена компонентов" }
            end
          end

          # Фильтр по роботу
          div do
            label(class: "block text-sm font-medium text-gray-700 mb-2") { "Робот" }
            select(
              name: "robot_id",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            ) do
              option(value: "", selected: @current_robot_id.nil?) { "Все роботы" }
              @robots.each do |robot|
                option(
                  value: robot.id,
                  selected: @current_robot_id.to_i == robot.id
                ) { robot.serial_number }
              end
            end
          end

          # Кнопки
          div(class: "flex items-end gap-2") do
            button(
              type: "submit",
              class: "px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500"
            ) { "Применить" }

            a(
              href: helpers.maintenance_records_path,
              class: "px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500"
            ) { "Сбросить" }
          end
        end
      end
    end

    def render_maintenance_records_table
      div(class: "bg-white rounded-lg shadow") do
        div(class: "px-6 py-4 border-b border-gray-200") do
          h2(class: "text-xl font-semibold") { "Список записей ТО" }
        end

        if @maintenance_records.any?
          div(class: "overflow-x-auto") do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead(class: "bg-gray-50") do
                tr do
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Робот" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Дата" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Тип" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Статус" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Техник" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Стоимость" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Действия" }
                end
              end

              tbody(class: "bg-white divide-y divide-gray-200") do
                @maintenance_records.each do |record|
                  render_maintenance_record_row(record)
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

    def render_maintenance_record_row(record)
      tr(class: "hover:bg-gray-50") do
        td(class: "px-6 py-4 whitespace-nowrap") do
          a(
            href: helpers.robot_path(record.robot),
            class: "text-blue-600 hover:text-blue-900"
          ) { record.robot.serial_number }
        end

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

        td(class: "px-6 py-4 whitespace-nowrap text-sm space-x-2") do
          a(href: helpers.maintenance_record_path(record), class: "text-blue-600 hover:text-blue-900") { "Просмотр" }
        end
      end
    end
  end
end
