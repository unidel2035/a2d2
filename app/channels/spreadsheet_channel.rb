class SpreadsheetChannel < ApplicationCable::Channel
  def subscribed
    spreadsheet = Spreadsheet.find(params[:spreadsheet_id])
    sheet = spreadsheet.sheets.find(params[:sheet_id])

    # Subscribe to this specific sheet's updates
    stream_for sheet
  end

  def unsubscribed
    # Any cleanup needed when channel is closed
  end

  def receive(data)
    # Handle incoming messages from clients
    case data['action']
    when 'cell_update'
      broadcast_cell_update(data)
    when 'row_added'
      broadcast_row_added(data)
    when 'column_added'
      broadcast_column_added(data)
    when 'cursor_position'
      broadcast_cursor_position(data)
    end
  end

  private

  def broadcast_cell_update(data)
    sheet = Sheet.find(params[:sheet_id])
    SpreadsheetChannel.broadcast_to(
      sheet,
      {
        type: 'cell_update',
        row_id: data['row_id'],
        column_key: data['column_key'],
        value: data['value'],
        formula: data['formula'],
        user_id: current_user&.id || 'anonymous'
      }
    )
  end

  def broadcast_row_added(data)
    sheet = Sheet.find(params[:sheet_id])
    SpreadsheetChannel.broadcast_to(
      sheet,
      {
        type: 'row_added',
        row: data['row'],
        user_id: current_user&.id || 'anonymous'
      }
    )
  end

  def broadcast_column_added(data)
    sheet = Sheet.find(params[:sheet_id])
    SpreadsheetChannel.broadcast_to(
      sheet,
      {
        type: 'column_added',
        column: data['column'],
        user_id: current_user&.id || 'anonymous'
      }
    )
  end

  def broadcast_cursor_position(data)
    sheet = Sheet.find(params[:sheet_id])
    SpreadsheetChannel.broadcast_to(
      sheet,
      {
        type: 'cursor_position',
        row_id: data['row_id'],
        column_key: data['column_key'],
        user_id: current_user&.id || 'anonymous',
        user_name: current_user&.email || 'Anonymous'
      }
    )
  end
end
