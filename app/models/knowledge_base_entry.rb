# KnowledgeBaseEntry - Agricultural knowledge base
# Ontological knowledge representation for decision support
# Based on conceptual materials: ontological approach to agricultural knowledge
class KnowledgeBaseEntry < ApplicationRecord
  CATEGORIES = %w[
    crop_management
    pest_disease
    soil_health
    weather_patterns
    equipment_operation
    market_analysis
    regulations
    best_practices
  ].freeze

  ENTRY_TYPES = %w[
    fact
    rule
    case_study
    best_practice
    research_finding
    regulation
    warning
  ].freeze

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :entry_type, presence: true, inclusion: { in: ENTRY_TYPES }
  validates :title, presence: true
  validates :confidence_level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  serialize :ontology_link, coder: JSON
  serialize :related_concepts, coder: JSON
  serialize :applicability_conditions, coder: JSON

  scope :by_category, ->(category) { where(category: category) }
  scope :by_type, ->(type) { where(entry_type: type) }
  scope :high_confidence, -> { where('confidence_level >= ?', 7) }
  scope :in_russian, -> { where(language: 'ru') }
  scope :recent, -> { where('created_at >= ?', 1.year.ago) }

  # Get category in Russian
  def category_ru
    case category
    when 'crop_management'
      'Управление посевами'
    when 'pest_disease'
      'Вредители и болезни'
    when 'soil_health'
      'Здоровье почвы'
    when 'weather_patterns'
      'Погодные условия'
    when 'equipment_operation'
      'Работа техники'
    when 'market_analysis'
      'Рыночный анализ'
    when 'regulations'
      'Регулирование'
    when 'best_practices'
      'Лучшие практики'
    else
      category.humanize
    end
  end

  # Get entry type in Russian
  def entry_type_ru
    case entry_type
    when 'fact'
      'Факт'
    when 'rule'
      'Правило'
    when 'case_study'
      'Кейс'
    when 'best_practice'
      'Лучшая практика'
    when 'research_finding'
      'Результат исследования'
    when 'regulation'
      'Норматив'
    when 'warning'
      'Предупреждение'
    else
      entry_type.humanize
    end
  end

  # Get confidence level description
  def confidence_description
    case confidence_level
    when 9..10
      'Очень высокая достоверность'
    when 7..8
      'Высокая достоверность'
    when 5..6
      'Средняя достоверность'
    when 3..4
      'Низкая достоверность'
    else
      'Очень низкая достоверность'
    end
  end

  # Check if applicable under given conditions
  def applicable?(conditions = {})
    return true if applicability_conditions.blank?

    applicability_conditions.all? do |key, required_value|
      conditions[key.to_sym] == required_value || conditions[key.to_s] == required_value
    end
  end

  # Get related entries
  def related_entries
    return [] unless related_concepts.present? && related_concepts.is_a?(Array)

    KnowledgeBaseEntry.where(id: related_concepts)
  end

  # Search in content
  def self.search(query)
    where('title LIKE ? OR content LIKE ?', "%#{query}%", "%#{query}%")
  end

  # Get ontology URI if available
  def ontology_uri
    ontology_link.dig('uri') if ontology_link.is_a?(Hash)
  end

  # Get full description
  def full_description
    parts = [category_ru, entry_type_ru, confidence_description]
    parts << "Источник: #{source}" if source.present?
    parts.join(' | ')
  end

  # Get applicability summary
  def applicability_summary
    return 'Применимо всегда' if applicability_conditions.blank?

    conditions = applicability_conditions.map { |k, v| "#{k}: #{v}" }.join(', ')
    "Условия: #{conditions}"
  end

  # Export to RDF/OWL format (simplified)
  def to_rdf
    {
      '@id' => ontology_uri || "agro:knowledge:#{id}",
      '@type' => "agro:#{entry_type}",
      'category' => category,
      'title' => title,
      'content' => content,
      'confidence' => confidence_level,
      'language' => language,
      'related' => related_concepts || []
    }
  end
end
