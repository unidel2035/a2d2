class SheetsController < ApplicationController
  before_action :set_spreadsheet
  before_action :set_sheet, only: [:show, :update, :destroy]

  # GET /spreadsheets/:spreadsheet_id/sheets/:id
  def show
    respond_to do |format|
      format.html { redirect_to spreadsheet_path(@spreadsheet, sheet_id: @sheet.id) }
      format.json { render json: sheet_data }
    end
  end

  # POST /spreadsheets/:spreadsheet_id/sheets
  def create
    @sheet = @spreadsheet.sheets.new(sheet_params)

    if @sheet.save
      respond_to do |format|
        format.html { redirect_to spreadsheet_path(@spreadsheet, sheet_id: @sheet.id), notice: 'Sheet created.' }
        format.json { render json: @sheet, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to @spreadsheet, alert: 'Failed to create sheet.' }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /spreadsheets/:spreadsheet_id/sheets/:id
  def update
    if @sheet.update(sheet_params)
      respond_to do |format|
        format.html { redirect_to spreadsheet_path(@spreadsheet, sheet_id: @sheet.id), notice: 'Sheet updated.' }
        format.json { render json: @sheet }
      end
    else
      respond_to do |format|
        format.html { redirect_to @spreadsheet, alert: 'Failed to update sheet.' }
        format.json { render json: @sheet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /spreadsheets/:spreadsheet_id/sheets/:id
  def destroy
    @sheet.destroy
    respond_to do |format|
      format.html { redirect_to @spreadsheet, notice: 'Sheet deleted.' }
      format.json { head :no_content }
    end
  end

  # POST /spreadsheets/:spreadsheet_id/sheets/:id/add_column
  def add_column
    set_sheet
    key = params[:key] || generate_column_key
    name = params[:name] || "Column #{key}"
    type = params[:type] || 'text'

    @sheet.add_column(key, name, type)

    respond_to do |format|
      format.json { render json: { success: true, sheet: @sheet } }
      format.html { redirect_to spreadsheet_path(@spreadsheet, sheet_id: @sheet.id), notice: 'Column added.' }
    end
  end

  # DELETE /spreadsheets/:spreadsheet_id/sheets/:id/remove_column/:column_key
  def remove_column
    set_sheet
    @sheet.remove_column(params[:column_key])

    respond_to do |format|
      format.json { render json: { success: true } }
      format.html { redirect_to spreadsheet_path(@spreadsheet, sheet_id: @sheet.id), notice: 'Column removed.' }
    end
  end

  private

  def set_spreadsheet
    @spreadsheet = Spreadsheet.find(params[:spreadsheet_id])
  end

  def set_sheet
    @sheet = @spreadsheet.sheets.find(params[:id])
  end

  def sheet_params
    params.require(:sheet).permit(:name, :position, column_definitions: [])
  end

  def sheet_data
    {
      id: @sheet.id,
      name: @sheet.name,
      columns: @sheet.column_definitions,
      rows: @sheet.rows.map(&:to_hash)
    }
  end

  def generate_column_key
    existing_keys = @sheet.column_keys
    ('A'..'ZZ').find { |key| !existing_keys.include?(key) } || "COL#{rand(1000)}"
  end
end
