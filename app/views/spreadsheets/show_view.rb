# frozen_string_literal: true

module Spreadsheets
  class ShowView < ApplicationComponent
    def initialize(spreadsheet:, current_sheet:)
      @spreadsheet = spreadsheet
      @current_sheet = current_sheet
    end

    def view_template
      div(class: "spreadsheet-editor", data: { controller: "spreadsheet" }) do
        # Header
        div(class: "editor-header") do
          div(class: "editor-title") do
            h1 { @spreadsheet.name }
            a(href: helpers.edit_spreadsheet_path(@spreadsheet), class: "btn btn-sm") { "Редактировать" }
            a(href: helpers.spreadsheets_path, class: "btn btn-sm") { "← К списку таблиц" }
          end

          div(class: "editor-actions") do
            button(class: "btn btn-sm", onclick: "addRow()") { "+ Добавить строку" }
            button(class: "btn btn-sm", onclick: "addColumn()") { "+ Добавить колонку" }
          end
        end

        # Sheet tabs
        div(class: "sheet-tabs") do
          @spreadsheet.sheets.each do |sheet|
            div(class: "sheet-tab #{'active' if sheet.id == @current_sheet.id}") do
              a(href: helpers.spreadsheet_path(@spreadsheet, sheet_id: sheet.id)) { sheet.name }
            end
          end
          button(class: "sheet-tab new-sheet", onclick: "addSheet()") { "+ Новый лист" }
        end

        # Spreadsheet grid
        div(class: "grid-container") do
          div(class: "grid-wrapper") do
            table(class: "spreadsheet-grid", id: "spreadsheet-grid") do
              thead do
                tr do
                  th(class: "row-header") { "#" }
                  @current_sheet.column_definitions.each do |col|
                    th(class: "column-header", data: { column: col['key'] || col[:key] }) do
                      span(class: "column-name") { col['name'] || col[:name] }
                      span(class: "column-type") { "(#{col['type'] || col[:type]})" }
                    end
                  end
                end
              end

              tbody do
                @current_sheet.rows.each do |row|
                  tr(data: { row_id: row.id, position: row.position }) do
                    td(class: "row-number") { row.position }
                    @current_sheet.column_definitions.each do |col|
                      column_key = col['key'] || col[:key]
                      cell = row.cells.find { |c| c.column_key == column_key }
                      td(
                        class: "cell",
                        data: {
                          row: row.id,
                          column: column_key,
                          type: col['type'] || col[:type],
                          formula: cell&.formula,
                          value: cell&.value
                        },
                        contenteditable: "true"
                      ) { cell&.computed_value || cell&.value }
                    end
                  end
                end

                # Empty rows for better UX
                if @current_sheet.rows.empty?
                  10.times do |i|
                    tr(class: "empty-row", data: { position: i + 1 }) do
                      td(class: "row-number") { i + 1 }
                      @current_sheet.column_definitions.each do |col|
                        td(
                          class: "cell empty",
                          data: {
                            column: col['key'] || col[:key],
                            type: col['type'] || col[:type]
                          },
                          contenteditable: "true"
                        )
                      end
                    end
                  end
                end
              end
            end
          end
        end

        # Formula bar
        div(class: "formula-bar", id: "formula-bar") do
          label { "Формула:" }
          input(
            type: "text",
            id: "formula-input",
            placeholder: "Введите формулу (например: =SUM(A1:A10))"
          )
          button(class: "btn btn-sm", onclick: "applyFormula()") { "Применить" }
        end
      end

      render_styles
      render_scripts
    end

    private

    def render_styles
      style do
        raw(<<~CSS.html_safe)
          * {
            box-sizing: border-box;
          }

          .spreadsheet-editor {
            height: 100vh;
            display: flex;
            flex-direction: column;
            background: #f8f9fa;
          }

          .editor-header {
            background: white;
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
            display: flex;
            justify-content: space-between;
            align-items: center;
          }

          .editor-title {
            display: flex;
            align-items: center;
            gap: 15px;
          }

          .editor-title h1 {
            margin: 0;
            font-size: 1.5rem;
            color: #2c3e50;
          }

          .editor-actions {
            display: flex;
            gap: 10px;
          }

          .sheet-tabs {
            background: white;
            display: flex;
            border-bottom: 2px solid #dee2e6;
            padding: 0 20px;
          }

          .sheet-tab {
            padding: 10px 20px;
            cursor: pointer;
            border: none;
            background: none;
            color: #666;
            border-bottom: 3px solid transparent;
            transition: all 0.2s ease;
          }

          .sheet-tab:hover {
            background: #f8f9fa;
          }

          .sheet-tab.active {
            color: #667eea;
            border-bottom-color: #667eea;
            font-weight: 600;
          }

          .sheet-tab a {
            text-decoration: none;
            color: inherit;
          }

          .sheet-tab.new-sheet {
            color: #999;
            font-weight: normal;
          }

          .grid-container {
            flex: 1;
            overflow: auto;
            padding: 20px;
          }

          .grid-wrapper {
            background: white;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            overflow: auto;
          }

          .spreadsheet-grid {
            width: 100%;
            border-collapse: collapse;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 14px;
          }

          .spreadsheet-grid th,
          .spreadsheet-grid td {
            border: 1px solid #dee2e6;
            padding: 8px 12px;
            min-width: 120px;
          }

          .spreadsheet-grid th {
            background: #f8f9fa;
            font-weight: 600;
            position: sticky;
            top: 0;
            z-index: 10;
          }

          .row-header,
          .row-number {
            background: #f8f9fa;
            text-align: center;
            font-weight: 600;
            min-width: 50px;
            max-width: 50px;
            color: #666;
            user-select: none;
          }

          .column-header {
            text-align: left;
            user-select: none;
          }

          .column-name {
            font-weight: 600;
            color: #2c3e50;
          }

          .column-type {
            font-size: 0.85em;
            color: #999;
            font-weight: normal;
          }

          .cell {
            background: white;
            cursor: text;
            transition: all 0.1s ease;
          }

          .cell:hover {
            background: #f0f4ff;
          }

          .cell:focus {
            outline: 2px solid #667eea;
            background: white;
            z-index: 5;
          }

          .cell.selected {
            outline: 2px solid #667eea;
            background: #f0f4ff;
          }

          .cell.empty {
            background: #fafafa;
          }

          .empty-row {
            opacity: 0.6;
          }

          .formula-bar {
            background: white;
            padding: 15px 20px;
            border-top: 1px solid #dee2e6;
            display: flex;
            align-items: center;
            gap: 10px;
          }

          .formula-bar label {
            font-weight: 600;
            color: #2c3e50;
          }

          .formula-bar input {
            flex: 1;
            padding: 8px 12px;
            border: 1px solid #dee2e6;
            border-radius: 4px;
            font-family: 'Courier New', monospace;
            font-size: 14px;
          }

          .formula-bar input:focus {
            outline: none;
            border-color: #667eea;
            box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
          }

          .btn {
            padding: 8px 16px;
            font-size: 0.9rem;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
            background: #667eea;
            color: white;
          }

          .btn:hover {
            background: #5568d3;
          }

          .btn-sm {
            padding: 6px 12px;
            font-size: 0.85rem;
          }
        CSS
      end
    end

    def render_scripts
      script do
        raw(<<~JS.html_safe)
          let currentCell = null;
          const spreadsheetId = #{@spreadsheet.id};
          const sheetId = #{@current_sheet.id};

          // Handle cell selection
          document.querySelectorAll('.cell').forEach(cell => {
            cell.addEventListener('focus', function() {
              currentCell = this;
              const formula = this.dataset.formula;
              if (formula) {
                document.getElementById('formula-input').value = '=' + formula;
              } else {
                document.getElementById('formula-input').value = '';
              }
              this.classList.add('selected');
            });

            cell.addEventListener('blur', function() {
              this.classList.remove('selected');
              saveCell(this);
            });

            cell.addEventListener('keydown', function(e) {
              if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                moveToNextRow(this);
              } else if (e.key === 'Tab') {
                e.preventDefault();
                moveToNextCell(this);
              }
            });
          });

          function saveCell(cellElement) {
            const rowId = cellElement.dataset.row;
            const columnKey = cellElement.dataset.column;
            const value = cellElement.textContent.trim();
            const formula = cellElement.dataset.formula || '';

            if (!rowId) {
              if (value) {
                createRowWithValue(cellElement, columnKey, value);
              }
              return;
            }

            fetch(`/spreadsheets/${spreadsheetId}/sheets/${sheetId}/rows/${rowId}/cells/${columnKey}`, {
              method: 'PATCH',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
              },
              body: JSON.stringify({
                value: value,
                formula: formula,
                data_type: cellElement.dataset.type
              })
            })
            .then(response => response.json())
            .then(data => {
              if (data.success) {
                cellElement.dataset.value = data.cell.value;
                if (data.cell.formula) {
                  cellElement.dataset.formula = data.cell.formula;
                }
              }
            })
            .catch(error => console.error('Error saving cell:', error));
          }

          function createRowWithValue(cellElement, columnKey, value) {
            const row = cellElement.closest('tr');
            const position = row.dataset.position;

            fetch(`/spreadsheets/${spreadsheetId}/sheets/${sheetId}/rows`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
              },
              body: JSON.stringify({
                data: {},
                cells: {
                  [columnKey]: {
                    value: value,
                    data_type: cellElement.dataset.type
                  }
                }
              })
            })
            .then(response => response.json())
            .then(data => {
              if (data.success) {
                row.dataset.rowId = data.row.id;
                row.classList.remove('empty-row');
                row.querySelectorAll('.cell').forEach(cell => {
                  cell.dataset.row = data.row.id;
                });
              }
            })
            .catch(error => console.error('Error creating row:', error));
          }

          function moveToNextCell(currentCell) {
            const cell = currentCell.nextElementSibling;
            if (cell && cell.classList.contains('cell')) {
              cell.focus();
            }
          }

          function moveToNextRow(currentCell) {
            const currentRow = currentCell.closest('tr');
            const nextRow = currentRow.nextElementSibling;
            if (nextRow) {
              const columnIndex = Array.from(currentRow.children).indexOf(currentCell);
              const nextCell = nextRow.children[columnIndex];
              if (nextCell && nextCell.classList.contains('cell')) {
                nextCell.focus();
              }
            }
          }

          function applyFormula() {
            if (!currentCell) {
              alert('Выберите ячейку');
              return;
            }

            const formulaInput = document.getElementById('formula-input');
            let formula = formulaInput.value.trim();

            if (formula.startsWith('=')) {
              formula = formula.substring(1);
            }

            currentCell.dataset.formula = formula;
            currentCell.textContent = '=' + formula;
            saveCell(currentCell);
          }

          function addRow() {
            fetch(`/spreadsheets/${spreadsheetId}/sheets/${sheetId}/rows`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
              },
              body: JSON.stringify({ data: {} })
            })
            .then(response => response.json())
            .then(data => {
              if (data.success) {
                location.reload();
              }
            })
            .catch(error => console.error('Error adding row:', error));
          }

          function addColumn() {
            const name = prompt('Название колонки:');
            if (!name) return;

            const type = prompt('Тип данных (text, number, date):', 'text');

            fetch(`/spreadsheets/${spreadsheetId}/sheets/${sheetId}/add_column`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
              },
              body: JSON.stringify({ name: name, type: type || 'text' })
            })
            .then(response => response.json())
            .then(data => {
              if (data.success) {
                location.reload();
              }
            })
            .catch(error => console.error('Error adding column:', error));
          }

          function addSheet() {
            const name = prompt('Название листа:');
            if (!name) return;

            fetch(`/spreadsheets/${spreadsheetId}/sheets`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
              },
              body: JSON.stringify({ sheet: { name: name } })
            })
            .then(response => response.json())
            .then(data => {
              if (data.id) {
                location.reload();
              }
            })
            .catch(error => console.error('Error adding sheet:', error));
          }
        JS
      end
    end
  end
end
