# frozen_string_literal: true

module Robots
  class NewView < ApplicationComponent
    def initialize(robot:)
      @robot = robot
    end

    def view_template
      div(class: "container mx-auto px-4 py-8 max-w-3xl") do
        div(class: "mb-6") do
          a(
            href: robots_path,
            class: "text-blue-600 hover:text-blue-900"
          ) { "← Назад к списку роботов" }
        end

        div(class: "bg-white rounded-lg shadow") do
          div(class: "px-6 py-4 border-b border-gray-200") do
            h1(class: "text-2xl font-bold") { "Регистрация нового робота" }
          end

          div(class: "px-6 py-6") do
            form(method: "post", action: robots_path) do
              input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

              render_form_fields

              div(class: "flex gap-3 pt-6") do
                button(
                  type: "submit",
                  class: "px-6 py-3 bg-green-600 text-white rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 font-medium"
                ) { "Зарегистрировать робота" }

                a(
                  href: robots_path,
                  class: "px-6 py-3 bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-gray-500 font-medium"
                ) { "Отмена" }
              end
            end
          end
        end
      end
    end

    private

    def render_form_fields
      div(class: "space-y-6") do
        # Серийный номер
        div do
          label(class: "block text-sm font-medium text-gray-700 mb-2", for: "robot_serial_number") do
            "Серийный номер *"
          end
          input(
            type: "text",
            name: "robot[serial_number]",
            id: "robot_serial_number",
            value: @robot.serial_number,
            required: true,
            class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          )
          if @robot.errors[:serial_number].any?
            p(class: "mt-1 text-sm text-red-600") { @robot.errors[:serial_number].join(", ") }
          end
        end

        # Производитель
        div do
          label(class: "block text-sm font-medium text-gray-700 mb-2", for: "robot_manufacturer") do
            "Производитель"
          end
          input(
            type: "text",
            name: "robot[manufacturer]",
            id: "robot_manufacturer",
            value: @robot.manufacturer,
            class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          )
        end

        # Модель
        div do
          label(class: "block text-sm font-medium text-gray-700 mb-2", for: "robot_model") do
            "Модель"
          end
          input(
            type: "text",
            name: "robot[model]",
            id: "robot_model",
            value: @robot.model,
            class: "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
          )
        end
      end
    end
  end
end
