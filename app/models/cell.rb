class Cell < ApplicationRecord
  # Associations
  belongs_to :row

  # Validations
  validates :column_key, presence: true
  validates :column_key, uniqueness: { scope: :row_id }

  # Instance methods
  def computed_value
    return nil if value.blank? && formula.blank?

    if formula.present?
      evaluate_formula
    else
      parse_typed_value
    end
  end

  def has_formula?
    formula.present?
  end

  def sheet
    row.sheet
  end

  def spreadsheet
    row.sheet.spreadsheet
  end

  private

  def evaluate_formula
    # Placeholder for formula evaluation
    # Will be implemented with FormulaEvaluator service
    begin
      FormulaEvaluator.evaluate(formula, row: row, cell: self)
    rescue => e
      "#ERROR: #{e.message}"
    end
  end

  def parse_typed_value
    return nil if value.blank?

    case data_type
    when 'integer'
      value.to_i
    when 'decimal', 'number'
      value.to_f
    when 'boolean'
      value.to_s.downcase == 'true'
    when 'date'
      Date.parse(value) rescue value
    when 'datetime'
      DateTime.parse(value) rescue value
    else
      value.to_s
    end
  end
end
