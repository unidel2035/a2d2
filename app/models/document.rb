class Document < ApplicationRecord
  include Searchable

  # DOC-006: Full-text search configuration
  SEARCHABLE_FIELDS = [:title, :content_text, :author, :description]

  # Enums
  enum :category, {
    passport: 0,
    certificate: 1,
    manual: 2,
    report: 3,
    contract: 4,
    invoice: 5,
    other: 99
  }

  enum :status, {
    draft: 0,
    processing: 1,
    active: 2,
    archived: 3,
    deleted: 4
  }

  # Associations
  belongs_to :robot
  belongs_to :user  # Кто загрузил документ
  has_one_attached :file
  belongs_to :parent, class_name: "Document", optional: true
  has_many :versions, class_name: "Document", foreign_key: :parent_id, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :category, presence: true
  validates :status, presence: true
  validates :robot, presence: true
  validates :version_number, numericality: { greater_than: 0 }

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }
  scope :expiring_soon, -> { where("expiry_date <= ?", 30.days.from_now).where("expiry_date >= ?", Time.current) }

  # Callbacks
  after_create :enqueue_classification
  after_create :enqueue_data_extraction
  before_save :extract_text_from_file, if: :file_attached?

  # Methods
  def file_attached?
    file.attached?
  end

  def create_new_version!
    transaction do
      new_version = self.dup
      new_version.parent_id = id
      new_version.version_number = versions.maximum(:version_number).to_i + 1
      new_version.save!
      new_version
    end
  end

  def latest_version
    versions.order(version_number: :desc).first || self
  end

  def expired?
    expiry_date && expiry_date < Date.current
  end

  private

  def enqueue_classification
    # DOC-001: Automatic classification using Analyzer Agent
    DocumentClassificationJob.perform_later(id) if file_attached?
  end

  def enqueue_data_extraction
    # DOC-002: Extract structured data using Transformer Agent
    DocumentDataExtractionJob.perform_later(id) if file_attached?
  end

  def extract_text_from_file
    # DOC-003: OCR for scanned documents
    # This will be implemented with Tesseract integration
    # For now, we'll extract text from PDF/text files
    if file.content_type&.include?("pdf")
      # PDF text extraction will be implemented
      self.content_text = "PDF text extraction pending"
    elsif file.content_type&.include?("text")
      self.content_text = file.download
    end
  end
end
