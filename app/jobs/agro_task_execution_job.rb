# Background job for executing agricultural agent tasks
class AgroTaskExecutionJob < ApplicationJob
  queue_as :default

  def perform(task_id)
    task = AgroTask.find(task_id)
    agent = task.agro_agent

    # Determine agent service class
    service_class = case agent.agent_type
                    when 'farmer'
                      AgroAgents::FarmerAgent
                    when 'logistics'
                      AgroAgents::LogisticsAgent
                    when 'processor'
                      AgroAgents::ProcessorAgent
                    when 'marketplace'
                      AgroAgents::MarketplaceAgent
                    else
                      AgroAgents::BaseAgroAgent
                    end

    # Execute task
    service = service_class.new(agent)
    service.execute_task(task)
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "AgroTask #{task_id} not found: #{e.message}"
  rescue => e
    Rails.logger.error "Error executing AgroTask #{task_id}: #{e.message}"
    task&.fail!(e.message) if task
  end
end
