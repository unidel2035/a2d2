# AgroAgent - Multi-agent system for agricultural ecosystem
# Represents economic agents in the agricultural sector (farmers, processors, logistics, retailers, regulators)
class AgroAgent < ApplicationRecord
  belongs_to :user, optional: true
  has_many :agro_tasks, dependent: :destroy
  has_many :farms, dependent: :nullify
  has_many :logistics_orders, dependent: :nullify
  has_many :processing_batches, dependent: :nullify
  has_many :market_offers, dependent: :nullify
  has_many :buyer_contracts, class_name: 'SmartContract', foreign_key: 'buyer_agent_id', dependent: :nullify
  has_many :seller_contracts, class_name: 'SmartContract', foreign_key: 'seller_agent_id', dependent: :nullify

  # Agent types based on economic roles
  AGENT_TYPES = %w[
    farmer
    logistics
    processor
    retailer
    regulator
    equipment_operator
    warehouse
    marketplace
    analytics
  ].freeze

  # Three-level architecture from the concept
  LEVELS = %w[
    iot_layer
    micro_meso
    macro
  ].freeze

  STATUSES = %w[active inactive offline].freeze

  validates :name, presence: true
  validates :agent_type, presence: true, inclusion: { in: AGENT_TYPES }
  validates :level, presence: true, inclusion: { in: LEVELS }
  validates :status, inclusion: { in: STATUSES }

  serialize :capabilities, coder: JSON
  serialize :configuration, coder: JSON

  scope :active, -> { where(status: 'active') }
  scope :by_type, ->(type) { where(agent_type: type) }
  scope :by_level, ->(level) { where(level: level) }
  scope :iot_layer, -> { where(level: 'iot_layer') }
  scope :micro_meso, -> { where(level: 'micro_meso') }
  scope :macro_level, -> { where(level: 'macro') }

  # Update heartbeat to track agent availability
  def heartbeat!
    update(last_heartbeat: Time.current, status: 'active')
  end

  # Check if agent is online (heartbeat within last 5 minutes)
  def online?
    last_heartbeat.present? && last_heartbeat > 5.minutes.ago
  end

  # Update success rate based on task completion
  def update_success_rate
    total = tasks_completed + tasks_failed
    return if total.zero?

    self.success_rate = (tasks_completed.to_f / total * 100).round(2)
    save
  end

  # Get agent capabilities as array
  def capability_list
    capabilities || []
  end

  # Check if agent has specific capability
  def has_capability?(capability)
    capability_list.include?(capability.to_s)
  end

  # Agent description based on type
  def description
    case agent_type
    when 'farmer'
      "Агент фермерского хозяйства - управление посевами, техникой и урожаем"
    when 'logistics'
      "Агент логистики - транспортировка и доставка продукции"
    when 'processor'
      "Агент переработки - производство и обработка продукции"
    when 'retailer'
      "Агент ритейла - продажа конечным потребителям"
    when 'regulator'
      "Агент регулятора - контроль и соблюдение стандартов"
    when 'equipment_operator'
      "Агент управления техникой - операции беспилотной и автономной техники"
    when 'warehouse'
      "Агент складского хозяйства - хранение и управление запасами"
    when 'marketplace'
      "Агент маркетплейса - сведение спроса и предложения"
    when 'analytics'
      "Агент аналитики - предиктивная аналитика и моделирование"
    else
      "Агент экосистемы АПК"
    end
  end
end
