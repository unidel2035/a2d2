class CellsController < ApplicationController
  before_action :set_context

  # PATCH/PUT /spreadsheets/:spreadsheet_id/sheets/:sheet_id/rows/:row_id/cells/:column_key
  def update
    value = params[:value]
    formula = params[:formula]
    data_type = params[:data_type] || 'text'

    @cell = @row.set_cell_value(
      params[:column_key],
      value,
      formula: formula,
      data_type: data_type
    )

    respond_to do |format|
      format.json do
        render json: {
          success: true,
          cell: {
            column_key: @cell.column_key,
            value: @cell.value,
            computed_value: @cell.computed_value,
            formula: @cell.formula,
            data_type: @cell.data_type
          }
        }
      end
      format.html do
        redirect_to spreadsheet_path(@spreadsheet, sheet_id: @sheet.id),
                    notice: 'Cell updated.'
      end
    end
  rescue => e
    respond_to do |format|
      format.json { render json: { success: false, error: e.message }, status: :unprocessable_entity }
      format.html { redirect_to @spreadsheet, alert: "Error: #{e.message}" }
    end
  end

  # POST /spreadsheets/:spreadsheet_id/sheets/:sheet_id/rows
  def create_row
    data = params[:data] || {}
    @row = @sheet.add_row(data)

    # Set cell values if provided
    if params[:cells].present?
      params[:cells].each do |col_key, cell_data|
        @row.set_cell_value(
          col_key,
          cell_data[:value],
          formula: cell_data[:formula],
          data_type: cell_data[:data_type]
        )
      end
    end

    respond_to do |format|
      format.json { render json: { success: true, row: @row.to_hash } }
      format.html { redirect_to spreadsheet_path(@spreadsheet, sheet_id: @sheet.id), notice: 'Row added.' }
    end
  end

  # DELETE /spreadsheets/:spreadsheet_id/sheets/:sheet_id/rows/:row_id
  def destroy_row
    @row.destroy

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_to spreadsheet_path(@spreadsheet, sheet_id: @sheet.id), notice: 'Row deleted.' }
    end
  end

  private

  def set_context
    @spreadsheet = Spreadsheet.find(params[:spreadsheet_id])
    @sheet = @spreadsheet.sheets.find(params[:sheet_id])
    @row = @sheet.rows.find(params[:row_id]) if params[:row_id]
  end
end
