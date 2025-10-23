import consumer from "./consumer"

// Store active spreadsheet subscription
let spreadsheetSubscription = null;

export function subscribeToSpreadsheet(spreadsheetId, sheetId) {
  if (spreadsheetSubscription) {
    spreadsheetSubscription.unsubscribe();
  }

  spreadsheetSubscription = consumer.subscriptions.create(
    {
      channel: "SpreadsheetChannel",
      spreadsheet_id: spreadsheetId,
      sheet_id: sheetId
    },
    {
      connected() {
        console.log("Connected to spreadsheet channel");
      },

      disconnected() {
        console.log("Disconnected from spreadsheet channel");
      },

      received(data) {
        console.log("Received data:", data);

        switch(data.type) {
          case 'cell_update':
            handleCellUpdate(data);
            break;
          case 'row_added':
            handleRowAdded(data);
            break;
          case 'column_added':
            handleColumnAdded(data);
            break;
          case 'cursor_position':
            handleCursorPosition(data);
            break;
        }
      },

      sendCellUpdate(rowId, columnKey, value, formula) {
        this.perform('receive', {
          action: 'cell_update',
          row_id: rowId,
          column_key: columnKey,
          value: value,
          formula: formula
        });
      },

      sendCursorPosition(rowId, columnKey) {
        this.perform('receive', {
          action: 'cursor_position',
          row_id: rowId,
          column_key: columnKey
        });
      }
    }
  );

  return spreadsheetSubscription;
}

function handleCellUpdate(data) {
  const cell = document.querySelector(
    `[data-row="${data.row_id}"][data-column="${data.column_key}"]`
  );

  if (cell && document.activeElement !== cell) {
    cell.textContent = data.value || data.formula;
    cell.dataset.value = data.value;
    cell.dataset.formula = data.formula;

    // Visual feedback for remote update
    cell.classList.add('remote-update');
    setTimeout(() => cell.classList.remove('remote-update'), 1000);
  }
}

function handleRowAdded(data) {
  // Reload page or dynamically add row
  console.log("Row added by another user:", data);
}

function handleColumnAdded(data) {
  // Reload page or dynamically add column
  console.log("Column added by another user:", data);
}

function handleCursorPosition(data) {
  // Show other users' cursors
  const cell = document.querySelector(
    `[data-row="${data.row_id}"][data-column="${data.column_key}"]`
  );

  if (cell) {
    showRemoteCursor(cell, data.user_name);
  }
}

function showRemoteCursor(cell, userName) {
  // Remove existing cursor indicator
  const existingCursor = cell.querySelector('.remote-cursor');
  if (existingCursor) {
    existingCursor.remove();
  }

  // Add cursor indicator
  const cursor = document.createElement('div');
  cursor.className = 'remote-cursor';
  cursor.textContent = userName;
  cell.appendChild(cursor);

  // Remove after 3 seconds
  setTimeout(() => cursor.remove(), 3000);
}
