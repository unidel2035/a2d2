class DocumentDataExtractionJob < ApplicationJob
  queue_as :default

  # DOC-002: Extract structured data using Transformer Agent
  def perform(document_id)
    document = Document.find(document_id)
    return unless document.file.attached?

    # Find available Transformer Agent
    agent = Agent.by_type("Agents::TransformerAgent").available.first

    if agent
      # Create agent task for data extraction
      task = agent.agent_tasks.create!(
        task_type: "extract_document_data",
        input_data: {
          document_id: document.id,
          file_url: document.file.url,
          content_text: document.content_text,
          category: document.category,
          expected_fields: determine_expected_fields(document.category)
        },
        priority: 5
      )

      document.update!(status: :processing)
    else
      Rails.logger.warn "No available Transformer Agent for data extraction"
    end
  end

  private

  def determine_expected_fields(category)
    case category
    when "passport"
      ["number", "issue_date", "expiry_date", "issuer"]
    when "certificate"
      ["certificate_number", "issue_date", "expiry_date", "holder_name"]
    when "invoice"
      ["invoice_number", "date", "total_amount", "vendor", "items"]
    when "contract"
      ["contract_number", "parties", "start_date", "end_date", "value"]
    else
      []
    end
  end
end
