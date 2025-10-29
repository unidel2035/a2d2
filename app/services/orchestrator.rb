class Orchestrator
  # Singleton pattern for orchestrator
  include Singleton

  attr_reader :distribution_strategy

  def initialize
    @distribution_strategy = :round_robin
    @last_agent_index = 0
  end

  # Agent lifecycle management
  def register_agent(name:, agent_type:, capabilities: [], endpoint: nil, metadata: {})
    agent = Agent.create!(
      name: name,
      agent_type: agent_type,
      capabilities: capabilities,
      endpoint: endpoint,
      metadata: metadata,
      status: 'inactive'
    )

    Rails.logger.info "Agent registered: #{agent.name} (#{agent.agent_type})"
    agent
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to register agent: #{e.message}"
    raise
  end

  def activate_agent(agent_id)
    agent = Agent.find(agent_id)
    agent.activate!
    Rails.logger.info "Agent activated: #{agent.name}"
    agent
  end

  def deactivate_agent(agent_id)
    agent = Agent.find(agent_id)
    agent.deactivate!
    Rails.logger.info "Agent deactivated: #{agent.name}"
    agent
  end

  def deregister_agent(agent_id)
    agent = Agent.find(agent_id)
    agent.agent_registry_entry&.deregister!
    Rails.logger.info "Agent deregistered: #{agent.name}"
    agent
  end

  # Task distribution
  def distribute_task(task)
    agent = select_agent_for_task(task)

    unless agent
      Rails.logger.warn "No suitable agent found for task #{task.id}"
      return false
    end

    task.assign_to!(agent)
    Rails.logger.info "Task #{task.id} assigned to agent #{agent.name}"

    # Enqueue the task for processing
    AgentTaskProcessorJob.perform_later(task.id)

    true
  rescue StandardError => e
    Rails.logger.error "Failed to distribute task #{task.id}: #{e.message}"
    false
  end

  def redistribute_failed_tasks
    retryable_tasks = AgentTask.retryable.limit(100)

    retryable_tasks.each do |task|
      task.retry!
      distribute_task(task)
    end

    retryable_tasks.count
  end

  # Distribution strategy management
  def set_distribution_strategy(strategy)
    unless [:round_robin, :least_loaded, :capability_match].include?(strategy)
      raise ArgumentError, "Invalid distribution strategy: #{strategy}"
    end

    @distribution_strategy = strategy
    Rails.logger.info "Distribution strategy set to: #{strategy}"
  end

  # Agent monitoring
  def monitor_agents
    agents = Agent.all
    stats = {
      total: agents.count,
      active: agents.active.count,
      idle: agents.idle.count,
      busy: agents.busy.count,
      failed: agents.failed.count,
      healthy: agents.healthy.count,
      recently_active: agents.recently_active.count
    }

    Rails.logger.info "Agent monitoring: #{stats.inspect}"
    stats
  end

  def handle_agent_failure(agent_id, reason: nil)
    agent = Agent.find(agent_id)
    agent.mark_failed!
    agent.agent_registry_entry&.record_failure!

    # Reassign running tasks to other agents
    running_tasks = agent.agent_tasks.running
    running_tasks.each do |task|
      task.fail!("Agent failure: #{reason}")
      task.retry! if task.can_retry?
      distribute_task(task) if task.pending?
    end

    Rails.logger.warn "Agent failure handled: #{agent.name} - #{reason}"
  end

  # Performance monitoring
  def get_performance_metrics
    {
      total_tasks: AgentTask.count,
      completed_tasks: AgentTask.completed.count,
      failed_tasks: AgentTask.failed.count,
      pending_tasks: AgentTask.pending.count,
      running_tasks: AgentTask.running.count,
      dead_letter_tasks: AgentTask.dead_letter.count,
      average_completion_time: calculate_average_completion_time,
      success_rate: calculate_success_rate
    }
  end

  private

  def select_agent_for_task(task)
    case @distribution_strategy
    when :round_robin
      select_agent_round_robin(task)
    when :least_loaded
      select_agent_least_loaded(task)
    when :capability_match
      select_agent_capability_match(task)
    else
      raise "Unknown distribution strategy: #{@distribution_strategy}"
    end
  end

  def select_agent_round_robin(task)
    eligible_agents = get_eligible_agents(task)
    return nil if eligible_agents.empty?

    @last_agent_index = (@last_agent_index + 1) % eligible_agents.size
    eligible_agents[@last_agent_index]
  end

  def select_agent_least_loaded(task)
    eligible_agents = get_eligible_agents(task)
    return nil if eligible_agents.empty?

    eligible_agents.min_by { |agent| agent.current_load }
  end

  def select_agent_capability_match(task)
    if task.required_capability.present?
      Agent.active
           .healthy
           .where("json_contains(capabilities, ?)", [task.required_capability].to_json)
           .order(health_score: :desc)
           .first
    else
      select_agent_least_loaded(task)
    end
  end

  def get_eligible_agents(task)
    agents = Agent.idle.healthy

    if task.required_capability.present?
      agents = agents.select { |agent| agent.has_capability?(task.required_capability) }
    end

    agents.to_a
  end

  def calculate_average_completion_time
    completed = AgentTask.completed.where.not(started_at: nil, completed_at: nil)
    return 0 if completed.empty?

    total_time = completed.sum { |task| task.duration || 0 }
    (total_time / completed.count).round(2)
  end

  def calculate_success_rate
    total = AgentTask.where(status: %w[completed failed dead_letter]).count
    return 100.0 if total.zero?

    successful = AgentTask.completed.count
    (successful.to_f / total * 100).round(2)
  end
end
