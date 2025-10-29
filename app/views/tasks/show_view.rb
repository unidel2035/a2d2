# frozen_string_literal: true

module Tasks
  class ShowView < ApplicationComponent
    def initialize(task:)
      @task = task
    end

    def view_template
      div(class: "container mx-auto px-4 py-8") do
        div(class: "mb-6") do
          a(
            href: tasks_path,
            class: "text-blue-600 hover:text-blue-900"
          ) { "← Назад к списку заданий" }
        end

        div(class: "bg-white rounded-lg shadow") do
          div(class: "px-6 py-4 border-b border-gray-200") do
            h1(class: "text-2xl font-bold") { "Задание #{@task.task_number}" }
          end

          div(class: "px-6 py-6") do
            div(class: "grid grid-cols-1 md:grid-cols-2 gap-6") do
              render_detail_field("Робот", @task.robot.serial_number)
              render_detail_field("Статус", task_status_text(@task.status))
              render_detail_field("Цель", @task.goal || "N/A")
              render_detail_field("Оператор", @task.operator ? @task.operator.email : "Не назначен")
              render_detail_field(
                "Плановая дата",
                @task.planned_date ? @task.planned_date.strftime("%d.%m.%Y %H:%M") : "N/A"
              )
              render_detail_field(
                "Местоположение",
                @task.location || "N/A"
              )
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

    def task_status_text(status)
      case status
      when "planned" then "Запланировано"
      when "in_progress" then "Выполняется"
      when "completed" then "Завершено"
      when "cancelled" then "Отменено"
      else status
      end
    end
  end
end
