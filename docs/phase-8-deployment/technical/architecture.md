# DOC-TECH-001: Architecture Documentation

**Version**: 1.0
**Last Updated**: 2025-10-28

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Load Balancer                         │
│                        (nginx/HAProxy)                       │
└───────────────────────┬─────────────────────────────────────┘
                        │
        ┌───────────────┴────────────────┐
        │                                │
┌───────▼────────┐              ┌────────▼───────┐
│  App Servers   │              │   App Servers  │
│  (Rails 8.1)   │              │   (Rails 8.1)  │
└───────┬────────┘              └────────┬───────┘
        │                                │
        └───────────────┬────────────────┘
                        │
        ┌───────────────┴────────────────┐
        │                                │
┌───────▼────────┐              ┌────────▼───────┐
│   PostgreSQL   │◄────repl.────┤   PostgreSQL   │
│    Primary     │              │    Replica     │
└───────┬────────┘              └────────────────┘
        │
        │
┌───────▼────────┐
│ Redis Cluster  │
│ (Cache+Queue)  │
└────────────────┘
```

### Technology Stack

**Backend**:
- Ruby 3.3.6
- Rails 8.1.0
- PostgreSQL 14+
- Redis 7+

**Frontend**:
- Hotwire (Turbo + Stimulus)
- ImportMap
- Tailwind CSS

**Infrastructure**:
- Docker & Docker Compose
- nginx
- Puma
- Solid Queue (background jobs)
- Solid Cache (caching)

**Monitoring**:
- Prometheus
- Grafana
- Loki

## Layer Architecture

### 1. Presentation Layer
- **Controllers**: Handle HTTP requests
- **Views**: Hotwire templates
- **Stimulus Controllers**: Client-side interactions

### 2. Business Logic Layer
- **Services**: Business logic encapsulation
- **Agents**: AI agent implementations
- **Orchestrator**: Agent coordination

### 3. Data Access Layer
- **Models**: ActiveRecord ORM
- **Repositories**: Data access patterns
- **Queries**: Complex queries

### 4. Integration Layer
- **API Controllers**: REST/GraphQL endpoints
- **Webhooks**: Event handlers
- **External Services**: Third-party integrations

## Key Components

### Meta-Layer (Agent Orchestration)

```ruby
# Orchestrator manages agent lifecycle
class AgentOrchestrator
  def assign_task(task, strategy: :capability_match)
    agent = select_agent(task, strategy)
    agent.execute(task)
    verify_result(agent, task)
  end

  private

  def select_agent(task, strategy)
    case strategy
    when :capability_match
      agents.find { |a| a.can_handle?(task) }
    when :least_loaded
      agents.min_by(&:current_load)
    when :round_robin
      agents.sample
    end
  end
end
```

### AI Agents

```ruby
# Base agent class
class BaseAgent
  include AgentMemory
  include AgentVerification

  def execute(task)
    with_context(task) do
      result = process(task)
      validate_result(result)
      store_in_memory(result)
      result
    end
  rescue => error
    handle_error(error, task)
  end

  private

  def process(task)
    raise NotImplementedError
  end
end

# Example: Analyzer Agent
class AnalyzerAgent < BaseAgent
  def process(task)
    data = task.payload
    llm_response = call_llm(
      model: 'gpt-4',
      prompt: build_analysis_prompt(data)
    )
    parse_analysis(llm_response)
  end
end
```

### Unified LLM API

```ruby
# app/services/llm_service.rb
class LLMService
  PROVIDERS = {
    openai: OpenAIClient,
    anthropic: AnthropicClient,
    deepseek: DeepSeekClient,
    google: GoogleClient
  }.freeze

  def call(model:, prompt:, **options)
    provider = detect_provider(model)
    client = PROVIDERS[provider].new
    
    with_fallback do
      client.complete(
        model: model,
        prompt: prompt,
        **options
      )
    end
  end

  private

  def with_fallback
    yield
  rescue => error
    fallback_provider = next_provider
    fallback_provider.complete(...)
  end
end
```

## Database Schema

### Core Tables

```sql
-- Users & Authentication
users (id, email, encrypted_password, role, ...)
sessions (id, user_id, token, expires_at, ...)

-- Documents
documents (id, user_id, filename, content_type, status, ...)
document_versions (id, document_id, version, changes, ...)
document_tags (id, document_id, tag_name, ...)

-- Processes
processes (id, name, definition, status, ...)
process_executions (id, process_id, status, started_at, ...)
process_steps (id, execution_id, step_type, input, output, ...)

-- AI Agents
agents (id, type, name, capabilities, status, ...)
agent_tasks (id, agent_id, task_type, payload, result, ...)
agent_metrics (id, agent_id, success_count, avg_duration, ...)

-- Integrations
integrations (id, service, credentials, config, ...)
integration_logs (id, integration_id, action, status, ...)
```

## Security Architecture

### Authentication Flow

```
User → Login → JWT Token → Request → Verify Token → Access Resource
```

### Authorization (RBAC)

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    case user.role
    when 'admin'
      can :manage, :all
    when 'manager'
      can :manage, Process
      can :read, Document
    when 'user'
      can :manage, Document, user_id: user.id
      can :read, Process
    end
  end
end
```

### Data Encryption

- **At Rest**: AES-256 via `attr_encrypted`
- **In Transit**: TLS 1.3
- **Secrets**: Rails credentials

## Deployment Architecture

### Production Deployment

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  app:
    image: a2d2:latest
    deploy:
      replicas: 3
      restart_policy:
        condition: on-failure
    environment:
      RAILS_ENV: production
      DATABASE_URL: ${DATABASE_URL}
      REDIS_URL: ${REDIS_URL}
    
  postgres-primary:
    image: postgres:14
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    
  postgres-replica:
    image: postgres:14
    environment:
      POSTGRES_PRIMARY_HOST: postgres-primary
    
  redis:
    image: redis:7-alpine
    command: redis-server --requirepass ${REDIS_PASSWORD}
    
  nginx:
    image: nginx:1.27
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
```

## Performance Considerations

### Caching Strategy

1. **Page Caching**: Static pages
2. **Fragment Caching**: Partial views
3. **Query Caching**: Database queries
4. **Redis Caching**: Application data

```ruby
# Example: Fragment caching
<% cache document do %>
  <%= render document %>
<% end %>

# Query result caching
Rails.cache.fetch("document_#{id}", expires_in: 1.hour) do
  Document.find(id)
end
```

### Background Jobs

```ruby
# app/jobs/document_processing_job.rb
class DocumentProcessingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer

  def perform(document_id)
    document = Document.find(document_id)
    
    # Extract text
    text = extract_text(document)
    
    # Classify document
    classification = AnalyzerAgent.new.classify(text)
    
    # Extract entities
    entities = AnalyzerAgent.new.extract_entities(text)
    
    document.update!(
      processed_text: text,
      classification: classification,
      entities: entities,
      status: 'processed'
    )
  end
end
```

## Monitoring & Observability

### Metrics Collected

- **Application**: Request rate, response time, error rate
- **Database**: Query performance, connection pool
- **Redis**: Hit rate, memory usage
- **Agents**: Task completion rate, accuracy
- **System**: CPU, memory, disk I/O

### Logging

```ruby
# Structured logging
Rails.logger.info({
  event: 'document_processed',
  document_id: document.id,
  duration_ms: duration,
  agent: 'AnalyzerAgent'
}.to_json)
```

## Scalability

### Horizontal Scaling

- Add more app servers behind load balancer
- Database read replicas for queries
- Redis cluster for distributed caching
- Agent instances can scale independently

### Vertical Scaling

- Increase server resources (CPU, RAM)
- Optimize database (indexes, queries)
- Tune application (connection pools, threads)

---

**For more details, see**:
- [Deployment Guide](deployment-guide.md)
- [API Documentation](../user/api-guide.md)
- [Contributing Guidelines](contributing.md)

**Document Version**: 1.0
**Last Updated**: 2025-10-28
