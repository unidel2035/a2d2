# frozen_string_literal: true

module MaintenanceMailer
  class UpcomingMaintenanceTechnicianView < ApplicationComponent
    def initialize(maintenance:, technician:)
      @maintenance = maintenance
      @technician = technician
    end

    def view_template
      div(class: "container") do
        div(class: "header") do
          h2 { "Напоминание о техническом обслуживании" }
        end

        div(class: "content") do
          p { "Здравствуйте, #{@technician.name}!" }

          render_urgency_message

          div(class: "details") do
            h3 { "Детали технического обслуживания:" }

            div(class: "detail-row") do
              span(class: "label") { "Робот:" }
              text "#{@maintenance.robot.serial_number} (#{@maintenance.robot.manufacturer})"
            end

            div(class: "detail-row") do
              span(class: "label") { "Дата ТО:" }
              text @maintenance.scheduled_date.strftime("%d.%m.%Y")
            end

            div(class: "detail-row") do
              span(class: "label") { "Тип обслуживания:" }
              text I18n.t("activerecord.attributes.maintenance_record.maintenance_types.#{@maintenance.maintenance_type}", default: @maintenance.maintenance_type)
            end

            if @maintenance.robot.location.present?
              div(class: "detail-row") do
                span(class: "label") { "Местоположение:" }
                text @maintenance.robot.location
              end
            end

            div(class: "detail-row") do
              span(class: "label") { "Наработка:" }
              text "#{@maintenance.robot.total_operation_hours} часов"
            end
          end

          p { "Пожалуйста, убедитесь в наличии необходимых инструментов и запасных частей." }

          if @maintenance.description.present?
            div(class: "details") do
              h4 { "Дополнительная информация:" }
              p { @maintenance.description }
            end
          end
        end

        div(class: "footer") do
          p { "Это автоматическое уведомление из системы A2D2" }
          p { "Если у вас есть вопросы, свяжитесь с вашим руководителем" }
        end
      end

      render_styles
    end

    private

    def render_urgency_message
      days_before = (@maintenance.scheduled_date.to_date - Date.today).to_i

      if days_before == 1
        p(class: "urgent") do
          text "⚠️ Напоминаем, что завтра запланировано техническое обслуживание робота."
        end
      elsif days_before == 3
        p { "Напоминаем, что через 3 дня запланировано техническое обслуживание робота." }
      else
        p { "Напоминаем, что через #{days_before} дней запланировано техническое обслуживание робота." }
      end
    end

    def render_styles
      style do
        unsafe_raw(<<~CSS)
          body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
          }
          .container {
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
          }
          .header {
            background-color: #4CAF50;
            color: white;
            padding: 20px;
            text-align: center;
            border-radius: 5px 5px 0 0;
          }
          .content {
            background-color: #f9f9f9;
            padding: 20px;
            border: 1px solid #ddd;
          }
          .details {
            background-color: white;
            padding: 15px;
            margin: 15px 0;
            border-left: 4px solid #4CAF50;
          }
          .detail-row {
            margin: 10px 0;
          }
          .label {
            font-weight: bold;
            color: #555;
          }
          .urgent {
            color: #ff5722;
            font-weight: bold;
          }
          .footer {
            text-align: center;
            padding: 20px;
            color: #777;
            font-size: 12px;
          }
        CSS
      end
    end
  end
end
