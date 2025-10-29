# frozen_string_literal: true

module Spreadsheets
  class EditView < ApplicationComponent
    def initialize(spreadsheet:)
      @spreadsheet = spreadsheet
    end

    def view_template
      div(class: "form-container") do
        h1 { "Редактировать таблицу" }

        form(action: helpers.spreadsheet_path(@spreadsheet), method: "post", class: "spreadsheet-form") do
          # Add PATCH method through hidden input
          input(type: "hidden", name: "_method", value: "PATCH")

          render_errors if @spreadsheet.errors.any?

          div(class: "form-group") do
            label(for: "spreadsheet_name") { "Название таблицы" }
            input(
              type: "text",
              id: "spreadsheet_name",
              name: "spreadsheet[name]",
              value: @spreadsheet.name,
              class: "form-control",
              autofocus: true
            )
          end

          div(class: "form-group") do
            label(for: "spreadsheet_description") { "Описание" }
            textarea(
              id: "spreadsheet_description",
              name: "spreadsheet[description]",
              class: "form-control",
              rows: 4
            ) { @spreadsheet.description }
          end

          div(class: "form-group") do
            label(for: "spreadsheet_public", class: "checkbox-label") do
              input(
                type: "checkbox",
                id: "spreadsheet_public",
                name: "spreadsheet[public]",
                value: "true",
                checked: @spreadsheet.public?
              )
              text " Сделать таблицу публичной"
            end
          end

          div(class: "form-actions") do
            button(type: "submit", class: "btn btn-primary") { "Сохранить изменения" }
            a(href: helpers.spreadsheet_path(@spreadsheet), class: "btn btn-secondary") { "Отмена" }
          end
        end
      end

      render_styles
    end

    private

    def render_errors
      div(class: "errors") do
        h3 { "#{@spreadsheet.errors.count} ошибка при обновлении таблицы:" }
        ul do
          @spreadsheet.errors.full_messages.each do |message|
            li { message }
          end
        end
      end
    end

    def render_styles
      style do
        unsafe_raw(<<~CSS)
          .form-container {
            max-width: 600px;
            margin: 40px auto;
            padding: 40px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
          }

          .form-container h1 {
            margin-bottom: 30px;
            color: #2c3e50;
          }

          .spreadsheet-form .form-group {
            margin-bottom: 20px;
          }

          .spreadsheet-form label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #333;
          }

          .spreadsheet-form .form-control {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 1rem;
            transition: border-color 0.2s ease;
          }

          .spreadsheet-form .form-control:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
          }

          .spreadsheet-form .checkbox-label {
            display: flex;
            align-items: center;
            cursor: pointer;
          }

          .spreadsheet-form input[type="checkbox"] {
            margin-right: 8px;
          }

          .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 30px;
          }

          .btn {
            padding: 10px 20px;
            font-size: 1rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
          }

          .btn-primary {
            background: #667eea;
            color: white;
          }

          .btn-primary:hover {
            background: #5568d3;
          }

          .btn-secondary {
            background: #6c757d;
            color: white;
          }

          .btn-secondary:hover {
            background: #5a6268;
          }

          .errors {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
          }

          .errors h3 {
            margin: 0 0 10px 0;
            font-size: 1rem;
          }

          .errors ul {
            margin: 0;
            padding-left: 20px;
          }
        CSS
      end
    end
  end
end
