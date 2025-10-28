class MemoryManager
  include Singleton

  # Context memory management
  def store_context(agent_id, key, value, ttl: 1.hour)
    agent = Agent.find(agent_id)

    memory = MemoryStore.find_or_initialize_by(
      agent: agent,
      memory_type: 'context',
      key: key
    )

    memory.value = value.to_s
    memory.expires_at = Time.current + ttl
    memory.save!

    Rails.logger.debug "Context stored for agent #{agent_id}: #{key}"
    memory
  end

  def get_context(agent_id, key)
    memory = MemoryStore.context
                        .active
                        .find_by(agent_id: agent_id, key: key)

    return nil unless memory

    memory.access!
    memory.value
  end

  def delete_context(agent_id, key)
    MemoryStore.context
               .find_by(agent_id: agent_id, key: key)
               &.destroy
  end

  # Long-term memory management
  def store_long_term(agent_id, key, value)
    agent = Agent.find(agent_id)

    memory = MemoryStore.find_or_initialize_by(
      agent: agent,
      memory_type: 'long_term',
      key: key
    )

    memory.value = value.to_s
    memory.expires_at = nil  # Long-term memories don't expire
    memory.priority = 10     # Higher priority than context
    memory.save!

    Rails.logger.debug "Long-term memory stored for agent #{agent_id}: #{key}"
    memory
  end

  def get_long_term(agent_id, key)
    memory = MemoryStore.long_term
                        .find_by(agent_id: agent_id, key: key)

    return nil unless memory

    memory.access!
    memory.value
  end

  # Shared memory management
  def store_shared(key, value, ttl: nil)
    # Shared memories don't belong to a specific agent
    memory = MemoryStore.find_or_initialize_by(
      agent_id: nil,
      memory_type: 'shared',
      key: key
    )

    memory.value = value.to_s
    memory.expires_at = ttl ? Time.current + ttl : nil
    memory.save!

    Rails.logger.debug "Shared memory stored: #{key}"
    memory
  end

  def get_shared(key)
    memory = MemoryStore.shared
                        .active
                        .find_by(key: key)

    return nil unless memory

    memory.access!
    memory.value
  end

  def delete_shared(key)
    MemoryStore.shared
               .find_by(key: key)
               &.destroy
  end

  # Cache integration with Solid Cache
  def cache_store(key, value, expires_in: 1.hour)
    Rails.cache.write(key, value, expires_in: expires_in)
    Rails.logger.debug "Cached: #{key} (expires in #{expires_in}s)"
  end

  def cache_fetch(key, expires_in: 1.hour, &block)
    Rails.cache.fetch(key, expires_in: expires_in, &block)
  end

  def cache_delete(key)
    Rails.cache.delete(key)
  end

  def cache_clear
    Rails.cache.clear
    Rails.logger.info "Cache cleared"
  end

  # Memory pruning strategies
  def prune_expired_memories
    count = MemoryStore.prune_expired!
    Rails.logger.info "Pruned #{count} expired memories"
    count
  end

  def prune_agent_memories(agent_id, strategy: :priority, keep_count: 100)
    agent = Agent.find(agent_id)

    case strategy
    when :priority
      count = MemoryStore.prune_by_priority!(agent, keep_count: keep_count)
    when :size
      count = MemoryStore.prune_by_size!(agent, max_total_mb: 100)
    else
      raise ArgumentError, "Unknown pruning strategy: #{strategy}"
    end

    Rails.logger.info "Pruned memories for agent #{agent_id} using #{strategy} strategy"
    count
  end

  def auto_prune_all_agents
    total_pruned = 0

    Agent.all.each do |agent|
      # Prune by size first
      total_pruned += MemoryStore.prune_by_size!(agent, max_total_mb: 50)

      # Then prune by priority to keep only top 200
      total_pruned += MemoryStore.prune_by_priority!(agent, keep_count: 200)
    end

    # Prune expired memories
    total_pruned += prune_expired_memories

    Rails.logger.info "Auto-pruned #{total_pruned} memories across all agents"
    total_pruned
  end

  # Memory statistics
  def get_memory_stats(agent_id: nil)
    memories = agent_id ? MemoryStore.where(agent_id: agent_id) : MemoryStore.all

    {
      total_memories: memories.count,
      by_type: {
        context: memories.context.count,
        long_term: memories.long_term.count,
        shared: memories.shared.count
      },
      active: memories.active.count,
      expired: memories.expired.count,
      total_size_mb: (memories.sum(:size_bytes) / 1.megabyte.to_f).round(2),
      average_size_kb: (memories.average(:size_bytes).to_f / 1.kilobyte).round(2),
      most_accessed: get_most_accessed_memories(memories, limit: 10),
      least_accessed: get_least_accessed_memories(memories, limit: 10)
    }
  end

  def get_agent_memory_usage(agent_id)
    agent = Agent.find(agent_id)
    memories = agent.memory_stores

    {
      agent_id: agent.id,
      agent_name: agent.name,
      total_memories: memories.count,
      context_memories: memories.context.count,
      long_term_memories: memories.long_term.count,
      total_size_mb: (memories.sum(:size_bytes) / 1.megabyte.to_f).round(2),
      active_memories: memories.active.count,
      expired_memories: memories.expired.count,
      top_memories: memories.order(access_count: :desc).limit(5).pluck(:key, :access_count)
    }
  end

  # Memory sharing between agents
  def share_memory_between_agents(from_agent_id, to_agent_id, key)
    source_memory = MemoryStore.find_by(agent_id: from_agent_id, key: key)

    unless source_memory
      Rails.logger.warn "Memory not found for sharing: #{key} (agent #{from_agent_id})"
      return nil
    end

    target_agent = Agent.find(to_agent_id)

    shared_memory = MemoryStore.create!(
      agent: target_agent,
      memory_type: source_memory.memory_type,
      key: "shared_#{key}",
      value: source_memory.value,
      metadata: source_memory.metadata.merge(
        shared_from: from_agent_id,
        shared_at: Time.current
      ),
      priority: source_memory.priority
    )

    Rails.logger.info "Memory shared from agent #{from_agent_id} to #{to_agent_id}: #{key}"
    shared_memory
  end

  def broadcast_memory_to_agents(key, value, agent_ids: nil, ttl: 1.hour)
    agents = agent_ids ? Agent.where(id: agent_ids) : Agent.active

    memories_created = 0

    agents.each do |agent|
      store_context(agent.id, key, value, ttl: ttl)
      memories_created += 1
    end

    Rails.logger.info "Broadcasted memory to #{memories_created} agents: #{key}"
    memories_created
  end

  # Memory search
  def search_memories(query, agent_id: nil, memory_type: nil)
    memories = MemoryStore.all
    memories = memories.where(agent_id: agent_id) if agent_id
    memories = memories.where(memory_type: memory_type) if memory_type

    results = memories.where('key LIKE ? OR value LIKE ?', "%#{query}%", "%#{query}%")
                      .order(access_count: :desc)
                      .limit(50)

    results.map do |memory|
      {
        id: memory.id,
        agent_id: memory.agent_id,
        key: memory.key,
        value_preview: memory.value.to_s[0..100],
        memory_type: memory.memory_type,
        access_count: memory.access_count,
        last_accessed: memory.last_accessed_at
      }
    end
  end

  private

  def get_most_accessed_memories(memories, limit: 10)
    memories.order(access_count: :desc)
            .limit(limit)
            .pluck(:key, :access_count)
  end

  def get_least_accessed_memories(memories, limit: 10)
    memories.order(access_count: :asc)
            .limit(limit)
            .pluck(:key, :access_count)
  end
end
