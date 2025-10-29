# frozen_string_literal: true

module Spreadsheets
  class IndexView < ApplicationComponent
    def initialize(spreadsheets:)
      @spreadsheets = spreadsheets
    end

    def view_template
      div(class: "spreadsheet-container") do
        render_header
        render_spreadsheets_grid
      end

      # Inline styles for consistency with original ERB
      render_styles
    end

    private

    def render_header
      div(class: "header") do
        h1 { "Табличный редактор" }
        a(
          href: new_spreadsheet_path,
          class: "btn btn-primary"
        ) { "Создать новую таблицу" }
      end
    end

    def render_spreadsheets_grid
      div(class: "spreadsheets-grid") do
        if @spreadsheets.any?
          @spreadsheets.each do |spreadsheet|
            render_spreadsheet_card(spreadsheet)
          end
        else
          render_empty_state
        end
      end
    end

    def render_spreadsheet_card(spreadsheet)
      div(class: "spreadsheet-card") do
        div(class: "spreadsheet-header") do
          h3 do
            a(href: spreadsheet_path(spreadsheet)) { spreadsheet.name }
          end
          span(class: "spreadsheet-meta") do
            spreadsheet.created_at.strftime("%d.%m.%Y")
          end
        end

        if spreadsheet.description.present?
          p(class: "spreadsheet-description") do
            truncate(spreadsheet.description, length: 150)
          end
        end

        div(class: "spreadsheet-footer") do
          span(class: "sheet-count") do
            "#{spreadsheet.sheets.count} #{pluralize_sheets(spreadsheet.sheets.count)}"
          end

          div(class: "spreadsheet-actions") do
            a(
              href: spreadsheet_path(spreadsheet),
              class: "btn btn-sm"
            ) { "Открыть" }

            a(
              href: spreadsheet_path(spreadsheet),
              class: "btn btn-sm btn-danger",
              data: { turbo_method: :delete, turbo_confirm: "Вы уверены?" }
            ) { "Удалить" }
          end
        end
      end
    end

    def render_empty_state
      div(class: "empty-state") do
        h3 { "Пока нет таблиц" }
        p { "Создайте свою первую таблицу для начала работы" }
        a(
          href: new_spreadsheet_path,
          class: "btn btn-primary"
        ) { "Создать таблицу" }
      end
    end

    def pluralize_sheets(count)
      return "лист" if count == 1
      return "листа" if count >= 2 && count <= 4

      "листов"
    end

    def render_styles
      style do
        raw <<~CSS
          .spreadsheet-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 40px 20px;
          }

          .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
          }

          .header h1 {
            font-size: 2rem;
            color: #2c3e50;
          }

          .spreadsheets-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
          }

          .spreadsheet-card {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            padding: 20px;
            transition: all 0.3s ease;
          }

          .spreadsheet-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transform: translateY(-2px);
          }

          .spreadsheet-header {
            display: flex;
            justify-content: space-between;
            align-items: start;
            margin-bottom: 10px;
          }

          .spreadsheet-header h3 {
            margin: 0;
            font-size: 1.3rem;
          }

          .spreadsheet-header h3 a {
            color: #667eea;
            text-decoration: none;
          }

          .spreadsheet-header h3 a:hover {
            text-decoration: underline;
          }

          .spreadsheet-meta {
            font-size: 0.85rem;
            color: #999;
          }

          .spreadsheet-description {
            color: #666;
            line-height: 1.6;
            margin: 10px 0;
          }

          .spreadsheet-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #f0f0f0;
          }

          .sheet-count {
            font-size: 0.9rem;
            color: #777;
          }

          .spreadsheet-actions {
            display: flex;
            gap: 10px;
          }

          .btn {
            display: inline-block;
            padding: 8px 16px;
            font-size: 0.95rem;
            text-decoration: none;
            border-radius: 4px;
            border: none;
            cursor: pointer;
            transition: all 0.2s ease;
          }

          .btn-primary {
            background: #667eea;
            color: white;
          }

          .btn-primary:hover {
            background: #5568d3;
          }

          .btn-sm {
            padding: 6px 12px;
            font-size: 0.85rem;
            background: #f8f9fa;
            color: #333;
          }

          .btn-sm:hover {
            background: #e9ecef;
          }

          .btn-danger {
            background: #dc3545;
            color: white;
          }

          .btn-danger:hover {
            background: #c82333;
          }

          .empty-state {
            grid-column: 1 / -1;
            text-align: center;
            padding: 60px 20px;
            background: #f8f9fa;
            border-radius: 8px;
          }

          .empty-state h3 {
            font-size: 1.5rem;
            color: #2c3e50;
            margin-bottom: 10px;
          }

          .empty-state p {
            color: #666;
            margin-bottom: 20px;
          }
        CSS
      end
    end
  end
end
