# SmartContract - Automated agreements between agents
class SmartContract < ApplicationRecord
  belongs_to :buyer_agent, class_name: 'AgroAgent'
  belongs_to :seller_agent, class_name: 'AgroAgent'

  CONTRACT_TYPES = %w[
    purchase_agreement
    supply_contract
    service_agreement
    logistics_contract
    processing_contract
  ].freeze

  STATUSES = %w[draft active fulfilled disputed cancelled].freeze

  validates :contract_type, presence: true, inclusion: { in: CONTRACT_TYPES }
  validates :status, inclusion: { in: STATUSES }

  serialize :terms, coder: JSON
  serialize :fulfillment_data, coder: JSON

  scope :active, -> { where(status: 'active') }
  scope :by_status, ->(status) { where(status: status) }
  scope :for_agent, ->(agent_id) { where('buyer_agent_id = ? OR seller_agent_id = ?', agent_id, agent_id) }

  def duration
    return nil unless execution_date && completion_date
    (completion_date - execution_date).to_i
  end

  def overdue?
    execution_date.present? && execution_date < Date.current && status != 'fulfilled'
  end

  def contract_terms
    terms || {}
  end
end
