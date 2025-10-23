class Row < ApplicationRecord
  # Associations
  belongs_to :sheet
  has_many :cells, dependent: :destroy

  # Validations
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  default_scope { order(position: :asc) }

  # Instance methods
  def cell_value(column_key)
    cell = cells.find_by(column_key: column_key)
    return nil unless cell

    if cell.formula.present?
      calculate_formula(cell.formula)
    else
      parse_value(cell.value, cell.data_type)
    end
  end

  def set_cell_value(column_key, value, formula: nil, data_type: 'text')
    cell = cells.find_or_initialize_by(column_key: column_key)
    cell.value = value
    cell.formula = formula
    cell.data_type = data_type || infer_data_type(value)
    cell.save!
    cell
  end

  def to_hash
    result = { id: id, position: position }
    sheet.column_keys.each do |key|
      result[key] = cell_value(key)
    end
    result
  end

  private

  def infer_data_type(value)
    return 'text' if value.nil?

    case value.to_s
    when /^\d+$/
      'integer'
    when /^\d+\.\d+$/
      'decimal'
    when /^(true|false)$/i
      'boolean'
    else
      'text'
    end
  end

  def parse_value(value, data_type)
    return nil if value.nil?

    case data_type
    when 'integer'
      value.to_i
    when 'decimal', 'number'
      value.to_f
    when 'boolean'
      value.to_s.downcase == 'true'
    else
      value.to_s
    end
  end

  def calculate_formula(formula)
    # Basic formula calculation - to be enhanced with FormulaEvaluator service
    # For now, return raw formula as string
    "=#{formula}"
  end
end
