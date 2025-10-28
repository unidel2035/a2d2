class DocumentClassificationJob < ApplicationJob
  queue_as :default

  # DOC-001: Automatic document classification using Analyzer Agent
  def perform(document_id)
    document = Document.find(document_id)
    return unless document.file.attached?

    # Find available Analyzer Agent
    agent = Agent.by_type("Agents::AnalyzerAgent").available.first

    if agent
      # Create agent task for classification
      task = agent.agent_tasks.create!(
        task_type: "classify_document",
        input_data: {
          document_id: document.id,
          file_url: document.file.url,
          content_text: document.content_text,
          title: document.title,
          description: document.description
        },
        priority: 5
      )

      # Wait for task completion (in real implementation, this would be async with callbacks)
      # For now, we'll just mark the document as processing
      document.update!(status: :processing)
    else
      Rails.logger.warn "No available Analyzer Agent for document classification"
    end
  end
end
