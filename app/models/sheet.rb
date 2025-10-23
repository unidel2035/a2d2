class Sheet < ApplicationRecord
  # Associations
  belongs_to :spreadsheet
  has_many :rows, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { minimum: 1, maximum: 255 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :set_default_position, on: :create
  after_initialize :set_default_columns, if: :new_record?

  # Scopes
  default_scope { order(position: :asc) }

  # Instance methods
  def add_column(key, name, type = 'text')
    columns = column_definitions || []
    columns << { key: key, name: name, type: type }
    update(column_definitions: columns)
  end

  def remove_column(key)
    columns = (column_definitions || []).reject { |col| col['key'] == key || col[:key] == key }
    update(column_definitions: columns)
    # Also delete cells with this column
    rows.each do |row|
      row.cells.where(column_key: key).destroy_all
    end
  end

  def column_keys
    (column_definitions || []).map { |col| col['key'] || col[:key] }
  end

  def column_by_key(key)
    (column_definitions || []).find { |col| (col['key'] || col[:key]) == key }
  end

  def add_row(data = {})
    position = rows.maximum(:position).to_i + 1
    rows.create!(position: position, data: data)
  end

  private

  def set_default_position
    self.position ||= spreadsheet.sheets.maximum(:position).to_i + 1 if spreadsheet
  end

  def set_default_columns
    self.column_definitions ||= [
      { key: 'A', name: 'Column A', type: 'text' },
      { key: 'B', name: 'Column B', type: 'text' },
      { key: 'C', name: 'Column C', type: 'number' }
    ]
  end
end
