# Phase 3: Agent Orchestration Layer - Implementation Guide

## Overview

Phase 3 implements the meta-layer for AI agent orchestration and management in the A2D2 platform. This layer provides the infrastructure for "AI managing AI" through sophisticated orchestration, task distribution, verification, and memory management systems.

## Architecture

```
┌─────────────────────────────────────────────┐
│           Orchestrator Layer                │
│  ┌───────────┐  ┌──────────────┐           │
│  │Task Queue │  │Agent Registry│           │
│  │ Manager   │  │              │           │
│  └─────┬─────┘  └──────┬───────┘           │
│        │               │                    │
│  ┌─────▼───────────────▼──────┐            │
│  │    Task Dispatcher          │            │
│  └─────┬───────────────────────┘            │
└────────┼────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│         Verification Layer                 │
│  ┌──────────┐    ┌──────────────┐         │
│  │Quality   │    │Memory         │         │
│  │Checker   │    │Management     │         │
│  └──────────┘    └──────────────┘         │
└────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────┐
│            Agent Layer                     │
│  (будет реализовано в Фазе 4)             │
└────────────────────────────────────────────┘
```

## Components

### 1. Database Models

#### Agent Model
Represents an AI agent in the system.

**Fields:**
- `name`: Unique identifier for the agent
- `agent_type`: Type of agent (analyzer, transformer, validator, etc.)
- `status`: Current status (inactive, idle, busy, failed)
- `capabilities`: JSON array of agent capabilities
- `version`: Agent version string
- `endpoint`: HTTP endpoint for agent communication
- `metadata`: Additional agent metadata
- `last_heartbeat`: Timestamp of last heartbeat
- `priority`: Agent priority for task assignment
- `health_score`: Agent health metric (0-100)

**Key Methods:**
- `activate!`, `deactivate!`: Lifecycle management
- `mark_busy!`, `mark_idle!`: Status transitions
- `heartbeat!`: Record agent heartbeat
- `has_capability?(capability)`: Check if agent has capability
- `can_handle_task?(task)`: Check if agent can process task

#### AgentTask Model
Represents a task to be processed by agents.

**Fields:**
- `task_type`: Type of task
- `status`: Task status (pending, assigned, running, completed, failed, dead_letter)
- `priority`: Task priority
- `payload`: Task input data (JSON)
- `result`: Task output data (JSON)
- `metadata`: Task metadata (JSON)
- `agent_id`: Assigned agent
- `parent_task_id`: Parent task for dependency tracking
- `deadline`: Task deadline
- `retry_count`: Number of retry attempts
- `max_retries`: Maximum allowed retries
- `error_message`: Error description if failed

**Key Methods:**
- `assign_to!(agent)`: Assign task to agent
- `start!`, `complete!`, `fail!`: State transitions
- `retry!`: Retry failed task
- `move_to_dead_letter!`: Move to dead letter queue

#### AgentRegistryEntry Model
Tracks agent registration and health.

**Fields:**
- `agent_id`: Reference to agent
- `registration_status`: Registration status
- `registered_at`: Registration timestamp
- `last_health_check`: Last health check timestamp
- `consecutive_failures`: Count of consecutive failures
- `health_check_data`: Health check metrics (JSON)
- `performance_metrics`: Performance metrics (JSON)
- `active`: Active status boolean

**Key Methods:**
- `record_heartbeat!`: Record successful heartbeat
- `record_failure!`: Record health check failure
- `suspend_agent!`: Suspend agent after failures
- `reactivate!`: Reactivate suspended agent

#### VerificationLog Model
Logs task result verification.

**Fields:**
- `agent_task_id`: Reference to task
- `agent_id`: Reference to agent
- `verification_type`: Type of verification
- `status`: Verification status (passed, failed, warning)
- `quality_score`: Quality score (0-100)
- `verification_data`: Verification metrics (JSON)
- `issues_found`: Array of issues
- `auto_reassigned`: Whether task was auto-reassigned
- `reassigned_to_task_id`: New task if reassigned

**Key Methods:**
- `needs_reassignment?`: Check if quality is too low
- `create_reassignment_task!`: Create new task for low quality results

#### MemoryStore Model
Manages agent memory and context.

**Fields:**
- `agent_id`: Reference to agent (null for shared memory)
- `memory_type`: Type (context, long_term, shared)
- `key`: Memory key
- `value`: Memory value (text)
- `metadata`: Memory metadata (JSON)
- `expires_at`: Expiration timestamp
- `access_count`: Number of accesses
- `last_accessed_at`: Last access timestamp
- `priority`: Memory priority
- `size_bytes`: Memory size in bytes

**Key Methods:**
- `access!`: Record memory access
- `expired?`: Check if memory expired
- `extend_expiration(duration)`: Extend expiration
- Class methods for shared memory and pruning

### 2. Service Layer

#### Orchestrator Service
Central orchestration service for agent lifecycle and task distribution.

**Methods:**
- `register_agent(...)`: Register new agent
- `activate_agent(id)`: Activate agent
- `deactivate_agent(id)`: Deactivate agent
- `distribute_task(task)`: Distribute task to agent
- `set_distribution_strategy(strategy)`: Set distribution strategy
- `monitor_agents()`: Get agent statistics
- `handle_agent_failure(id, reason)`: Handle agent failures
- `get_performance_metrics()`: Get performance metrics

**Distribution Strategies:**
- `:round_robin`: Distribute tasks evenly across agents
- `:least_loaded`: Assign to agent with lowest current load
- `:capability_match`: Match task requirements to agent capabilities

#### TaskQueueManager Service
Manages task queue with prioritization and dependencies.

**Methods:**
- `enqueue_task(...)`: Create new task
- `enqueue_batch(tasks_data)`: Create multiple tasks
- `reprioritize_task(id, priority)`: Change task priority
- `check_deadlines()`: Find overdue tasks
- `process_dead_letter_queue()`: Get dead letter stats
- `retry_dead_letter_task(id)`: Retry dead letter task
- `queue_statistics()`: Get queue statistics
- `cleanup_completed_tasks(older_than)`: Clean old tasks
- `move_failed_to_dead_letter()`: Move exhausted tasks

#### VerificationLayer Service
Validates task results and maintains quality standards.

**Methods:**
- `verify_task_result(task_id, verification_types)`: Verify task
- `verify_schema(task)`: Validate result schema
- `verify_business_rules(task)`: Validate business rules
- `verify_data_quality(task)`: Check data quality
- `verify_completeness(task)`: Check result completeness
- `verify_performance(task)`: Check performance metrics
- `generate_quality_report(...)`: Generate quality reports
- `get_agent_quality_metrics(agent_id)`: Get agent quality metrics

**Quality Thresholds:**
- High: ≥90
- Medium: ≥70
- Low: ≥50
- Auto-reassignment: <50

#### MemoryManager Service
Manages agent memory with caching and pruning.

**Methods:**
- `store_context(agent_id, key, value, ttl)`: Store context memory
- `get_context(agent_id, key)`: Retrieve context memory
- `store_long_term(agent_id, key, value)`: Store long-term memory
- `get_long_term(agent_id, key)`: Retrieve long-term memory
- `store_shared(key, value, ttl)`: Store shared memory
- `get_shared(key)`: Retrieve shared memory
- `cache_store/fetch/delete(key)`: Solid Cache integration
- `prune_expired_memories()`: Remove expired memories
- `auto_prune_all_agents()`: Auto-prune all agents
- `get_memory_stats(agent_id)`: Get memory statistics
- `share_memory_between_agents(...)`: Share memory
- `broadcast_memory_to_agents(...)`: Broadcast to all agents

### 3. Background Jobs

#### AgentTaskProcessorJob
Processes assigned tasks.

**Responsibilities:**
- Execute task on agent endpoint
- Handle task completion or failure
- Trigger verification after completion
- Implement retry logic

#### TaskDistributionJob
Distributes pending tasks to agents.

**Responsibilities:**
- Find suitable agent for task
- Assign task to agent
- Schedule retry if no agent available

#### AgentHeartbeatJob
Checks agent health.

**Responsibilities:**
- Ping agent health endpoint
- Record heartbeat or failure
- Update agent health metrics

#### VerificationJob
Verifies completed task results.

**Responsibilities:**
- Run configured verification types
- Calculate quality score
- Create reassignment task if needed

#### MemoryPruningJob
Prunes old and expired memories.

**Responsibilities:**
- Remove expired memories
- Apply pruning strategies
- Free up memory space

#### DeadlineCheckerJob
Checks task deadlines.

**Responsibilities:**
- Find overdue tasks
- Increase priority for overdue tasks
- Move exhausted tasks to dead letter

#### AgentMonitoringJob
Monitors agent health and status.

**Responsibilities:**
- Check agent heartbeats
- Detect inactive agents
- Trigger heartbeat checks
- Handle timeouts

### 4. API Endpoints

#### Agents API (`/api/v1/agents`)

**Endpoints:**
- `GET /api/v1/agents` - List all agents
- `GET /api/v1/agents/:id` - Get agent details
- `POST /api/v1/agents` - Register new agent
- `PATCH /api/v1/agents/:id` - Update agent
- `DELETE /api/v1/agents/:id` - Deregister agent
- `POST /api/v1/agents/:id/activate` - Activate agent
- `POST /api/v1/agents/:id/deactivate` - Deactivate agent
- `POST /api/v1/agents/:id/heartbeat` - Send heartbeat
- `GET /api/v1/agents/stats` - Get agent statistics

#### Tasks API (`/api/v1/tasks`)

**Endpoints:**
- `GET /api/v1/tasks` - List tasks (with filtering)
- `GET /api/v1/tasks/:id` - Get task details
- `POST /api/v1/tasks` - Create new task
- `POST /api/v1/tasks/batch_create` - Create multiple tasks
- `POST /api/v1/tasks/:id/retry` - Retry failed task
- `POST /api/v1/tasks/:id/cancel` - Cancel task
- `GET /api/v1/tasks/stats` - Get queue statistics
- `GET /api/v1/tasks/dead_letter` - Get dead letter queue stats

#### Monitoring API (`/api/v1/monitoring`)

**Endpoints:**
- `GET /api/v1/monitoring/dashboard` - Get dashboard data
- `GET /api/v1/monitoring/agents/:id/metrics` - Get agent metrics
- `GET /api/v1/monitoring/quality_report` - Get quality report
- `GET /api/v1/monitoring/memory_stats` - Get memory statistics
- `GET /api/v1/monitoring/health` - System health check

### 5. Admin UI

**Routes:**
- `/agents` - Agent list with statistics
- `/agents/:id` - Agent details with tasks

**Features:**
- Real-time agent status display
- Health score visualization
- Task history
- Capability tags
- Performance metrics

## Usage Examples

### Registering an Agent

```ruby
orchestrator = Orchestrator.instance

agent = orchestrator.register_agent(
  name: "analyzer-001",
  agent_type: "analyzer",
  capabilities: ["data_analysis", "pattern_recognition"],
  endpoint: "http://agent.example.com:8000",
  metadata: { version: "1.0.0" }
)

orchestrator.activate_agent(agent.id)
```

### Creating and Distributing Tasks

```ruby
task_manager = TaskQueueManager.instance

task = task_manager.enqueue_task(
  task_type: "data_analysis",
  payload: { dataset_id: 123, analysis_type: "statistical" },
  priority: 10,
  deadline: 1.hour.from_now,
  required_capability: "data_analysis",
  metadata: {
    verification: {
      types: [:schema, :data_quality, :completeness],
      required_fields: ["results", "metrics"]
    }
  }
)
```

### Verifying Task Results

```ruby
verifier = VerificationLayer.instance

result = verifier.verify_task_result(
  task.id,
  verification_types: [:schema, :business_rules, :data_quality]
)

puts "Overall Score: #{result[:overall_score]}"
puts "Quality Level: #{result[:quality_level]}"
puts "Needs Reassignment: #{result[:needs_reassignment]}"
```

### Managing Memory

```ruby
memory_manager = MemoryManager.instance

# Store context memory
memory_manager.store_context(
  agent.id,
  "current_analysis",
  analysis_data.to_json,
  ttl: 30.minutes
)

# Store long-term knowledge
memory_manager.store_long_term(
  agent.id,
  "learned_patterns",
  patterns.to_json
)

# Share memory across agents
memory_manager.broadcast_memory_to_agents(
  "global_config",
  config.to_json,
  agent_ids: Agent.active.pluck(:id)
)
```

## Configuration

### Solid Queue Setup

Solid Queue is used for background job processing. Configuration in `config/application.rb`:

```ruby
config.active_job.queue_adapter = :solid_queue
```

### Solid Cache Setup

Solid Cache is used for memory caching. Configuration in `config/environments/production.rb`:

```ruby
config.cache_store = :solid_cache_store
```

## Scheduled Jobs

Add to your scheduler (e.g., cron, whenever, or Solid Queue recurring jobs):

```ruby
# Every 1 minute
AgentMonitoringJob.perform_later

# Every 5 minutes
DeadlineCheckerJob.perform_later

# Every 30 minutes
MemoryPruningJob.perform_later
```

## Performance Metrics

### Key Metrics
- **Task Distribution Latency**: <100ms
- **Agent Registration Time**: <1s
- **Heartbeat Interval**: 30s
- **Failed Task Retry**: max 3 attempts
- **Memory Cache Hit Rate**: >80%
- **Test Coverage**: >90% for core services

### Success Criteria
- ✓ Orchestrator successfully manages agents
- ✓ Task Queue correctly distributes tasks
- ✓ Agent Registry tracks agent status
- ✓ Verification Layer validates results
- ✓ Memory Management efficiently manages memory
- ✓ Integration tests pass (>85% coverage)
- ✓ Performance tests pass (100+ concurrent tasks)

## Testing

Run tests:

```bash
# All tests
bin/rails test

# Model tests
bin/rails test test/models

# Service tests
bin/rails test test/services

# Integration tests
bin/rails test test/integration

# Performance tests
bin/rails test test/performance
```

## Monitoring and Debugging

### Logs

```ruby
# View orchestrator logs
Rails.logger.tagged("Orchestrator") do
  Rails.logger.info "Agent registered: #{agent.name}"
end
```

### Metrics Dashboard

Access the monitoring dashboard:
- API: `GET /api/v1/monitoring/dashboard`
- UI: `/agents`

### Health Checks

```bash
# System health
curl http://localhost:3000/api/v1/monitoring/health

# Agent metrics
curl http://localhost:3000/api/v1/monitoring/agents/1/metrics

# Quality report
curl http://localhost:3000/api/v1/monitoring/quality_report
```

## Security Considerations

- API endpoints use CSRF protection (disabled for API namespace)
- Agent authentication should be added for production
- Task payloads should be validated
- Memory access should be restricted by agent

## Next Steps

Phase 4 will implement:
- Actual AI agents (Analyzer, Transformer, Validator, Reporter, Integration)
- Unified LLM API supporting multiple providers
- Agent-specific business logic
- Advanced agent communication protocols

## Related Documentation

- [Development Plan](../docs/DEVELOPMENT_PLAN.md)
- [Phase 3 Issue](https://github.com/unidel2035/a2d2/issues/21)
- [Database Schema](../db/schema.rb)

## License

This is part of the A2D2 project.
