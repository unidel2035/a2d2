# AgroOrchestrator - Meta-layer for coordinating multi-agent system
class AgroOrchestrator
  attr_reader :coordination

  def initialize
    @coordination = nil
  end

  # Assign task to appropriate agent based on capabilities
  def assign_task(task_type, input_data, options = {})
    suitable_agents = find_suitable_agents(task_type, options)

    return { error: 'No suitable agents found' } if suitable_agents.empty?

    # Load balancing - pick least loaded agent
    agent = suitable_agents.min_by { |a| a.agro_tasks.pending.count }

    task = agent.agro_tasks.create!(
      task_type: task_type,
      priority: options[:priority] || 'normal',
      input_data: input_data
    )

    # Execute task asynchronously
    AgroTaskExecutionJob.perform_later(task.id)

    { success: true, task_id: task.id, agent_id: agent.id }
  end

  # Coordinate multiple agents for complex workflow
  def coordinate_workflow(workflow_type, participating_agent_ids, workflow_data = {})
    @coordination = AgentCoordination.create!(
      coordination_type: workflow_type,
      participating_agents: participating_agent_ids,
      coordination_data: workflow_data,
      started_at: Time.current,
      status: 'active'
    )

    # Execute coordination workflow
    case workflow_type
    when 'workflow'
      execute_sequential_workflow(participating_agent_ids, workflow_data)
    when 'negotiation'
      facilitate_negotiation(participating_agent_ids, workflow_data)
    when 'optimization'
      optimize_resources(participating_agent_ids, workflow_data)
    else
      { error: 'Unknown coordination type' }
    end
  end

  # Monitor all agents in the system
  def monitor_ecosystem
    agents = AgroAgent.all
    offline_agents = agents.reject(&:online?)

    {
      total_agents: agents.count,
      active_agents: agents.active.count,
      online_agents: agents.count - offline_agents.count,
      offline_agents: offline_agents.map { |a| { id: a.id, name: a.name, last_heartbeat: a.last_heartbeat } },
      pending_tasks: AgroTask.pending.count,
      active_coordinations: AgentCoordination.active.count
    }
  end

  # Health check for agents
  def health_check
    agents = AgroAgent.all

    agents.map do |agent|
      {
        agent_id: agent.id,
        name: agent.name,
        status: agent.status,
        online: agent.online?,
        success_rate: agent.success_rate,
        pending_tasks: agent.agro_tasks.pending.count,
        last_heartbeat: agent.last_heartbeat
      }
    end
  end

  # Rebalance tasks across agents
  def rebalance_tasks
    overloaded_threshold = 10
    overloaded_agents = AgroAgent.active.select do |agent|
      agent.agro_tasks.pending.count > overloaded_threshold
    end

    rebalanced = 0

    overloaded_agents.each do |agent|
      excess_tasks = agent.agro_tasks.pending.order(priority: :asc).limit(5)

      excess_tasks.each do |task|
        suitable_agents = find_suitable_agents(task.task_type, level: agent.level)
                            .where.not(id: agent.id)

        next if suitable_agents.empty?

        target_agent = suitable_agents.min_by { |a| a.agro_tasks.pending.count }

        if target_agent.agro_tasks.pending.count < overloaded_threshold - 5
          task.update(agro_agent: target_agent)
          rebalanced += 1
        end
      end
    end

    { rebalanced_tasks: rebalanced, overloaded_agents: overloaded_agents.count }
  end

  private

  def find_suitable_agents(task_type, options = {})
    agents = AgroAgent.active

    # Filter by level if specified
    agents = agents.by_level(options[:level]) if options[:level]

    # Filter by capabilities
    agents.select { |a| a.capability_list.include?(task_type.to_s) }
  end

  def execute_sequential_workflow(agent_ids, workflow_data)
    results = []

    agent_ids.each_with_index do |agent_id, index|
      agent = AgroAgent.find(agent_id)
      step_data = workflow_data['steps']&.[](index) || {}

      task = agent.agro_tasks.create!(
        task_type: step_data['task_type'] || 'execution',
        input_data: step_data['input'] || {},
        priority: 'high'
      )

      results << { agent_id: agent_id, task_id: task.id }
    end

    coordination.update(coordination_data: coordination.data.merge(workflow_results: results))

    { success: true, tasks_created: results.count, results: results }
  end

  def facilitate_negotiation(agent_ids, negotiation_data)
    # Create negotiation space for agents
    {
      success: true,
      negotiation_id: coordination.id,
      participants: agent_ids,
      message: 'Negotiation facilitated'
    }
  end

  def optimize_resources(agent_ids, optimization_data)
    agents = AgroAgent.where(id: agent_ids)

    # Collect resource data from all participating agents
    resources = agents.map do |agent|
      {
        agent_id: agent.id,
        type: agent.agent_type,
        available_capacity: calculate_capacity(agent)
      }
    end

    { success: true, resources: resources, optimization: 'completed' }
  end

  def calculate_capacity(agent)
    max_tasks = 20
    current_tasks = agent.agro_tasks.pending.count
    (max_tasks - current_tasks).clamp(0, max_tasks)
  end
end
