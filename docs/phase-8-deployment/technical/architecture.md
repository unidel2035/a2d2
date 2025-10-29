# DOC-TECH-001: Документация по архитектуре

**Версия**: 1.0
**Последнее обновление**: 2025-10-28

## Архитектура системы

### Высокоуровневая архитектура

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

### Технологический стек

**Backend**:
- Ruby 3.3.6
- Rails 8.1.0
- PostgreSQL 14+
- Redis 7+

**Frontend**:
- Hotwire (Turbo + Stimulus)
- ImportMap
- Tailwind CSS

**Инфраструктура**:
- Docker & Docker Compose
- nginx
- Puma
- Solid Queue (фоновые задачи)
- Solid Cache (кеширование)

**Мониторинг**:
- Prometheus
- Grafana
- Loki

## Слоистая архитектура

### 1. Слой представления
- **Контроллеры**: Обработка HTTP-запросов
- **Представления**: Шаблоны Hotwire
- **Stimulus-контроллеры**: Взаимодействие на стороне клиента

### 2. Слой бизнес-логики
- **Сервисы**: Инкапсуляция бизнес-логики
- **Агенты**: Реализации AI-агентов
- **Оркестратор**: Координация агентов

### 3. Слой доступа к данным
- **Модели**: ActiveRecord ORM
- **Репозитории**: Паттерны доступа к данным
- **Запросы**: Сложные запросы

### 4. Слой интеграции
- **API-контроллеры**: REST/GraphQL endpoints
- **Webhooks**: Обработчики событий
- **Внешние сервисы**: Интеграции со сторонними сервисами

## Ключевые компоненты

### Мета-слой (оркестрация агентов)

```ruby
# Orchestrator управляет жизненным циклом агентов
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

### AI-агенты

```ruby
# Базовый класс агента
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

# Пример: агент-анализатор
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

### Унифицированный LLM API

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

## Схема базы данных

### Основные таблицы

```sql
-- Пользователи и аутентификация
users (id, email, encrypted_password, role, ...)
sessions (id, user_id, token, expires_at, ...)

-- Документы
documents (id, user_id, filename, content_type, status, ...)
document_versions (id, document_id, version, changes, ...)
document_tags (id, document_id, tag_name, ...)

-- Процессы
processes (id, name, definition, status, ...)
process_executions (id, process_id, status, started_at, ...)
process_steps (id, execution_id, step_type, input, output, ...)

-- AI-агенты
agents (id, type, name, capabilities, status, ...)
agent_tasks (id, agent_id, task_type, payload, result, ...)
agent_metrics (id, agent_id, success_count, avg_duration, ...)

-- Интеграции
integrations (id, service, credentials, config, ...)
integration_logs (id, integration_id, action, status, ...)
```

## Архитектура безопасности

### Поток аутентификации

```
Пользователь → Вход → JWT Token → Запрос → Проверка токена → Доступ к ресурсу
```

### Авторизация (RBAC)

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

### Шифрование данных

- **В состоянии покоя**: AES-256 через `attr_encrypted`
- **При передаче**: TLS 1.3
- **Секреты**: Rails credentials

## Архитектура развертывания

### Production-развертывание

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

## Вопросы производительности

### Стратегия кеширования

1. **Кеширование страниц**: Статические страницы
2. **Фрагментарное кеширование**: Частичные представления
3. **Кеширование запросов**: Запросы к базе данных
4. **Redis-кеширование**: Данные приложения

```ruby
# Пример: фрагментарное кеширование
<% cache document do %>
  <%= render document %>
<% end %>

# Кеширование результатов запросов
Rails.cache.fetch("document_#{id}", expires_in: 1.hour) do
  Document.find(id)
end
```

### Фоновые задачи

```ruby
# app/jobs/document_processing_job.rb
class DocumentProcessingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer

  def perform(document_id)
    document = Document.find(document_id)

    # Извлечение текста
    text = extract_text(document)

    # Классификация документа
    classification = AnalyzerAgent.new.classify(text)

    # Извлечение сущностей
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

## Мониторинг и наблюдаемость

### Собираемые метрики

- **Приложение**: Частота запросов, время отклика, частота ошибок
- **База данных**: Производительность запросов, пул соединений
- **Redis**: Коэффициент попаданий, использование памяти
- **Агенты**: Показатель завершения задач, точность
- **Система**: CPU, память, дисковый I/O

### Логирование

```ruby
# Структурированное логирование
Rails.logger.info({
  event: 'document_processed',
  document_id: document.id,
  duration_ms: duration,
  agent: 'AnalyzerAgent'
}.to_json)
```

## Масштабируемость

### Горизонтальное масштабирование

- Добавление большего количества серверов приложений за балансировщиком нагрузки
- Реплики базы данных для чтения запросов
- Redis-кластер для распределенного кеширования
- Экземпляры агентов могут масштабироваться независимо

### Вертикальное масштабирование

- Увеличение ресурсов сервера (CPU, RAM)
- Оптимизация базы данных (индексы, запросы)
- Настройка приложения (пулы соединений, потоки)

---

**Для получения дополнительной информации см.**:
- [Руководство по развертыванию](deployment-guide.md)
- [Документация API](../user/api-guide.md)
- [Руководство по внесению вклада](contributing.md)

**Версия документа**: 1.0
**Последнее обновление**: 2025-10-28
