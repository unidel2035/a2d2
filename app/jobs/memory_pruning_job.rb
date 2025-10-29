class MemoryPruningJob < ApplicationJob
  queue_as :low_priority

  def perform
    memory_manager = MemoryManager.instance

    Rails.logger.info "Starting memory pruning job"

    # Prune expired memories
    expired_count = memory_manager.prune_expired_memories

    # Auto-prune all agents
    total_pruned = memory_manager.auto_prune_all_agents

    Rails.logger.info "Memory pruning completed: #{expired_count} expired, #{total_pruned} total pruned"

    {
      expired_pruned: expired_count,
      total_pruned: total_pruned
    }
  end
end
