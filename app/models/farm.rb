# Farm - Agricultural enterprise
class Farm < ApplicationRecord
  belongs_to :agro_agent, optional: true
  belongs_to :user, optional: true
  has_many :crops, dependent: :destroy
  has_many :equipment, dependent: :destroy

  FARM_TYPES = %w[crop livestock mixed processing greenhouse].freeze

  validates :name, presence: true
  validates :farm_type, inclusion: { in: FARM_TYPES }, allow_nil: true

  serialize :coordinates, coder: JSON

  scope :by_type, ->(type) { where(farm_type: type) }
  scope :with_agent, -> { where.not(agro_agent_id: nil) }

  def total_crops_area
    crops.sum(:area_planted)
  end

  def active_crops
    crops.where.not(status: 'harvested')
  end

  def available_equipment
    equipment.where(status: 'available')
  end
end
