class SpreadsheetsController < ApplicationController
  before_action :set_spreadsheet, only: [:show, :edit, :update, :destroy]

  # GET /spreadsheets
  def index
    spreadsheets = Spreadsheet.all.order(created_at: :desc)
    render Spreadsheets::IndexView.new(spreadsheets: spreadsheets)
  end

  # GET /spreadsheets/:id
  def show
    current_sheet = @spreadsheet.sheets.first || @spreadsheet.sheets.create!(name: 'Sheet 1')
    render Spreadsheets::ShowView.new(spreadsheet: @spreadsheet, current_sheet: current_sheet)
  end

  # GET /spreadsheets/new
  def new
    @spreadsheet = Spreadsheet.new
    render Spreadsheets::NewView.new(spreadsheet: @spreadsheet)
  end

  # POST /spreadsheets
  def create
    @spreadsheet = Spreadsheet.new(spreadsheet_params)
    # TODO: Set owner_id to current_user.id when authentication is implemented
    @spreadsheet.owner_id = 1 # Placeholder

    if @spreadsheet.save
      # Create first sheet
      @spreadsheet.sheets.create!(name: 'Sheet 1')
      redirect_to @spreadsheet, notice: 'Spreadsheet was successfully created.'
    else
      render Spreadsheets::NewView.new(spreadsheet: @spreadsheet), status: :unprocessable_entity
    end
  end

  # GET /spreadsheets/:id/edit
  def edit
    render Spreadsheets::EditView.new(spreadsheet: @spreadsheet)
  end

  # PATCH/PUT /spreadsheets/:id
  def update
    if @spreadsheet.update(spreadsheet_params)
      redirect_to @spreadsheet, notice: 'Spreadsheet was successfully updated.'
    else
      render Spreadsheets::EditView.new(spreadsheet: @spreadsheet), status: :unprocessable_entity
    end
  end

  # DELETE /spreadsheets/:id
  def destroy
    @spreadsheet.destroy
    redirect_to spreadsheets_url, notice: 'Spreadsheet was successfully deleted.'
  end

  private

  def set_spreadsheet
    @spreadsheet = Spreadsheet.find(params[:id])
  end

  def spreadsheet_params
    params.require(:spreadsheet).permit(:name, :description, :public)
  end
end
