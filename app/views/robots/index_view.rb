# frozen_string_literal: true

module Robots
  class IndexView < ApplicationComponent
    def initialize(robots:, stats:, manufacturers:, current_status: nil, current_manufacturer: nil, search_query: nil)
      @robots = robots
      @stats = stats
      @manufacturers = manufacturers
      @current_status = current_status
      @current_manufacturer = current_manufacturer
      @search_query = search_query
    end

    def view_template
      div(class: "container mx-auto px-4 py-8") do
        h1(class: "text-3xl font-bold mb-6") { "Управление роботами" }

        # Stats Cards
        render_stats_cards

        # Filters and Search
        render_filters

        # Action Buttons
        render_action_buttons

        # Robots Table
        render_robots_table
      end
    end

    private

    def render_stats_cards
      div(class: "grid grid-cols-1 md:grid-cols-5 gap-4 mb-8") do
        render_stat_card("Всего роботов", @stats[:total], "bg-white")
        render_stat_card("Активные", @stats[:active], "bg-green-50", "text-green-600")
        render_stat_card("На ТО", @stats[:maintenance], "bg-yellow-50", "text-yellow-600")
        render_stat_card("В ремонте", @stats[:repair], "bg-orange-50", "text-orange-600")
        render_stat_card("Списаны", @stats[:retired], "bg-gray-50", "text-gray-600")
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
        form(method: "get", action: helpers.robots_path, class: "grid grid-cols-1 md:grid-cols-4 gap-4") do
          # Поиск по серийному номеру
          div do
            label(class: "block text-sm font-medium text-gray-700 mb-2") { "Поиск по серийному номеру" }
            input(
              type: "text",
              name: "search",
              value: @search_query,
              placeholder: "Введите серийный номер",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            )
          end

          # Фильтр по статусу
          div do
            label(class: "block text-sm font-medium text-gray-700 mb-2") { "Статус" }
            select(
              name: "status",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            ) do
              option(value: "", selected: @current_status.nil?) { "Все статусы" }
              option(value: "active", selected: @current_status == "active") { "Активные" }
              option(value: "maintenance", selected: @current_status == "maintenance") { "На ТО" }
              option(value: "repair", selected: @current_status == "repair") { "В ремонте" }
              option(value: "retired", selected: @current_status == "retired") { "Списаны" }
            end
          end

          # Фильтр по производителю
          div do
            label(class: "block text-sm font-medium text-gray-700 mb-2") { "Производитель" }
            select(
              name: "manufacturer",
              class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            ) do
              option(value: "", selected: @current_manufacturer.nil?) { "Все производители" }
              @manufacturers.each do |manufacturer|
                option(
                  value: manufacturer,
                  selected: @current_manufacturer == manufacturer
                ) { manufacturer }
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
              href: helpers.robots_path,
              class: "px-4 py-2 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500"
            ) { "Сбросить" }
          end
        end
      end
    end

    def render_action_buttons
      div(class: "mb-6 flex justify-end") do
        a(
          href: helpers.new_robot_path,
          class: "px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 font-medium"
        ) { "+ Зарегистрировать нового робота" }
      end
    end

    def render_robots_table
      div(class: "bg-white rounded-lg shadow") do
        div(class: "px-6 py-4 border-b border-gray-200") do
          h2(class: "text-xl font-semibold") { "Список роботов" }
        end

        if @robots.any?
          div(class: "overflow-x-auto") do
            table(class: "min-w-full divide-y divide-gray-200") do
              thead(class: "bg-gray-50") do
                tr do
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Серийный номер" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Производитель" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Модель" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Статус" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Наработка (ч)" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Последнее ТО" }
                  th(class: "px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider") { "Действия" }
                end
              end

              tbody(class: "bg-white divide-y divide-gray-200") do
                @robots.each do |robot|
                  render_robot_row(robot)
                end
              end
            end
          end
        else
          div(class: "px-6 py-8 text-center text-gray-500") do
            "Нет роботов"
          end
        end
      end
    end

    def render_robot_row(robot)
      tr(class: "hover:bg-gray-50") do
        td(class: "px-6 py-4 whitespace-nowrap") do
          a(
            href: helpers.robot_path(robot),
            class: "text-blue-600 hover:text-blue-900 font-medium"
          ) { robot.serial_number }
        end

        td(class: "px-6 py-4 whitespace-nowrap") { robot.manufacturer || "N/A" }
        td(class: "px-6 py-4 whitespace-nowrap") { robot.model || "N/A" }

        td(class: "px-6 py-4 whitespace-nowrap") do
          status_class = case robot.status
          when "active" then "bg-green-100 text-green-800"
          when "maintenance" then "bg-yellow-100 text-yellow-800"
          when "repair" then "bg-orange-100 text-orange-800"
          when "retired" then "bg-gray-100 text-gray-800"
          else "bg-gray-100 text-gray-800"
          end

          status_text = case robot.status
          when "active" then "Активен"
          when "maintenance" then "На ТО"
          when "repair" then "В ремонте"
          when "retired" then "Списан"
          else robot.status
          end

          span(class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{status_class}") do
            status_text
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap") do
          robot.total_operation_hours&.round(1) || 0
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm text-gray-500") do
          if robot.last_maintenance_date
            robot.last_maintenance_date.strftime("%d.%m.%Y")
          else
            "Не проводилось"
          end
        end

        td(class: "px-6 py-4 whitespace-nowrap text-sm space-x-2") do
          a(href: helpers.robot_path(robot), class: "text-blue-600 hover:text-blue-900") { "Просмотр" }
          a(href: helpers.edit_robot_path(robot), class: "text-indigo-600 hover:text-indigo-900") { "Изменить" }
        end
      end
    end
  end
end
