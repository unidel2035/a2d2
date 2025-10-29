class InspectionReport < ApplicationRecord
  # Enums
  enum :status, {
    draft: 0,
    completed: 1,
    approved: 2
  }

  # Associations
  belongs_to :task
  has_many_attached :photos
  has_many_attached :videos

  # Validations
  validates :report_number, presence: true, uniqueness: true
  validates :status, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :pending_approval, -> { where(status: :completed) }

  # ROB-005: Inspection reports
  def add_media(files)
    files.each do |file|
      if file.content_type&.start_with?("image/")
        photos.attach(file)
      elsif file.content_type&.start_with?("video/")
        videos.attach(file)
      end
    end
  end

  def add_annotation(media_id, annotation_text, coordinates = {})
    current_metadata = metadata || {}
    annotations = current_metadata["annotations"] || []

    annotations << {
      media_id: media_id,
      text: annotation_text,
      coordinates: coordinates,
      created_at: Time.current
    }

    update!(metadata: current_metadata.merge("annotations" => annotations))
  end

  def complete!
    update!(status: :completed, inspection_date: Date.current)
  end

  def approve!
    update!(status: :approved)
  end

  # Export methods
  def export_to_pdf
    # Use Reporter Agent for PDF generation
    agent = Agent.by_type("Agents::ReporterAgent").available.first
    if agent
      task = agent.agent_tasks.create!(
        task_type: "generate_inspection_pdf",
        input_data: {
          inspection_report_id: id,
          include_photos: true,
          include_videos: false
        }
      )
      { status: "queued", task_id: task.id }
    else
      { status: "error", message: "No available Reporter Agent" }
    end
  end

  def export_to_kml
    # Generate KML file for geographic data
    require "builder"

    xml = Builder::XmlMarkup.new(indent: 2)
    kml_content = xml.kml(xmlns: "http://www.opengis.net/kml/2.2") do
      xml.Document do
        xml.name report_number
        xml.description findings

        if coordinates.present?
          lat, lng = coordinates.split(",").map(&:to_f)
          xml.Placemark do
            xml.name location
            xml.description recommendations
            xml.Point do
              xml.coordinates "#{lng},#{lat},0"
            end
          end
        end

        # Add photo placemarks if they have geotags
        photos.each_with_index do |photo, index|
          # Extract EXIF geotags if available
          # This is a placeholder for actual EXIF parsing
        end
      end
    end

    kml_content
  end

  def total_media_size
    (photos.sum(&:byte_size) + videos.sum(&:byte_size)) / 1024.0 / 1024.0 # Size in MB
  end

  def within_size_limit?
    total_media_size <= 2048 # 2GB limit
  end
end
