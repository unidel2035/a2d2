# 🤖 AI Orchestration System (Hive Mind Integration)

## Обзор

Система оркестрации ИИ-агентов в A2D2 реализует концепции из проекта [hive-mind](https://github.com/konard/hive-mind), создавая самоорганизующуюся экосистему интеллектуальных агентов, которая управляется мета-слоем координации.

## Архитектура

### Основные компоненты

```
┌─────────────────────────────────────────────────────────────┐
│                     Orchestrator                             │
│              (Главный координатор)                           │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        │             │             │
┌───────▼──────┐ ┌───▼───────┐ ┌──▼────────────┐
│ Agent        │ │   Task    │ │ Verification  │
│ Registry     │ │   Queue   │ │ Layer         │
│              │ │  Manager  │ │               │
└──────────────┘ └───────────┘ └───────────────┘
        │             │             │
        └─────────────┼─────────────┘
                      │
        ┌─────────────▼─────────────┐
        │  Consensus Mechanism       │
        └────────────────────────────┘
```

### 1. Agent Registry (Реестр агентов)

**Назначение:** Управление жизненным циклом агентов, мониторинг heartbeat и отслеживание capabilities.

**Основные функции:**
- Регистрация новых агентов в системе
- Мониторинг heartbeat и определение offline агентов
- Отслеживание загрузки и производительности агентов
- Перераспределение задач от offline агентов

**Использование:**

```ruby
# Регистрация агента
agent = Orchestration::AgentRegistry.register(
  agent_type: "Agents::AnalyzerAgent",
  name: "Data Analyzer #1",
  capabilities: { statistical_analysis: true, anomaly_detection: true },
  specializations: ["financial_data", "time_series"]
)

# Обновление heartbeat
Orchestration::AgentRegistry.heartbeat(agent.id)

# Проверка здоровья системы
health = Orchestration::AgentRegistry.system_health
# => {
#   total_agents: 10,
#   active: 8,
#   idle: 5,
#   busy: 3,
#   offline: 2,
#   health_percentage: 80.0,
#   load_distribution: [...]
# }
```

### 2. Task Queue Manager (Менеджер очереди задач)

**Назначение:** Приоритизация, распределение и retry-логика для задач агентов.

**Стратегии распределения:**
- `:least_loaded` - выбор наименее загруженного агента
- `:round_robin` - циклическое распределение
- `:capability_match` - лучшее соответствие capabilities
- `:high_performer` - выбор высокопроизводительных агентов

**Использование:**

```ruby
# Добавление задачи в очередь
task = Orchestration::TaskQueueManager.enqueue(
  task_type: "data_analysis",
  input_data: { dataset: "sales_2024.csv" },
  priority: 8,
  deadline: 1.hour.from_now,
  dependencies: [previous_task_id]
)

# Назначение задачи агенту
assignment = Orchestration::TaskQueueManager.assign_task(
  task.id,
  strategy: :least_loaded
)

# Статистика очереди
stats = Orchestration::TaskQueueManager.queue_stats
# => {
#   pending: 15,
#   processing: 5,
#   completed: 120,
#   failed: 3,
#   overdue: 1
# }
```

### 3. Verification Layer (Слой верификации)

**Назначение:** Контроль качества работы агентов и верификация результатов.

**Возможности:**
- Автоматическая верификация выполненных задач
- Peer review с участием нескольких агентов
- Расчет консенсуса между агентами-ревьюерами
- Retry при провале верификации

**Использование:**

```ruby
# Верификация задачи
result = Orchestration::VerificationLayer.verify_task(task.id)
# => {
#   passed: true,
#   quality_score: 87.5,
#   checks: { has_output: true, no_errors: true, ... }
# }

# Запрос peer review
review = Orchestration::VerificationLayer.request_peer_review(
  task.id,
  reviewer_count: 3
)

# Расчет консенсуса
consensus = Orchestration::VerificationLayer.calculate_consensus(
  collaboration.id
)
# => {
#   consensus_reached: true,
#   average_quality: 85.3,
#   agreement_percentage: 95.0
# }
```

### 4. Consensus Mechanism (Механизм консенсуса)

**Назначение:** Коллаборация между агентами и принятие решений на основе консенсуса.

**Типы коллаборации:**
- `review` - peer review выполненной работы
- `consensus` - совместное выполнение задачи
- `assistance` - помощь основному агенту

**Использование:**

```ruby
# Создание consensus задачи
result = Orchestration::ConsensusMechanism.create_consensus_task(
  task_type: "complex_analysis",
  input_data: { dataset: "complex_data.csv" },
  required_agents: 3,
  consensus_threshold: 0.7
)

# Выполнение с консенсусом
execution = Orchestration::ConsensusMechanism.execute_consensus_task(
  result[:collaboration].id
)

# Голосование агентов
vote_result = Orchestration::ConsensusMechanism.conduct_vote(
  task.id,
  voting_agents: [agent1, agent2, agent3],
  question: "Should we proceed with this approach?"
)
```

### 5. Orchestrator (Главный оркестратор)

**Назначение:** Центральный координатор, управляющий всей системой агентов.

**Основные функции:**
- Запуск и остановка системы
- Обработка очереди задач
- Мониторинг здоровья системы
- Оптимизация и балансировка нагрузки
- Масштабирование пула агентов

**Использование:**

```ruby
# Запуск оркестратора
Orchestration::Orchestrator.start

# Обработка очереди
Orchestration::Orchestrator.process_queue(
  strategy: :least_loaded,
  batch_size: 10
)

# Проверка здоровья
health = Orchestration::Orchestrator.health_check
# => {
#   status: "healthy",
#   agents: {...},
#   queue: {...},
#   recommendations: []
# }

# Оптимизация системы
Orchestration::Orchestrator.optimize

# Масштабирование
Orchestration::Orchestrator.scale_agents(
  agent_type: "Agents::AnalyzerAgent",
  target_count: 5
)

# Статистика
stats = Orchestration::Orchestrator.statistics(since: 24.hours.ago)
```

## Фоновые задачи

Система использует Solid Queue для автоматического выполнения фоновых задач:

### HeartbeatMonitorJob
Мониторит heartbeat агентов каждые 5 минут и отмечает неактивные агенты как offline.

### TaskQueueProcessorJob
Обрабатывает очередь задач каждую минуту, распределяя их между доступными агентами.

### SystemOptimizationJob
Выполняет оптимизацию системы каждые 15 минут:
- Перебалансировка нагрузки
- Retry провалившихся задач
- Верификация ожидающих задач

### TaskExecutionJob
Выполняет отдельную задачу агента.

### AgentReviewJob
Выполняет peer review задачи одним из агентов-ревьюеров.

## Модели данных

### Agent (расширен)
Новые поля для оркестрации:
- `load_score` - текущая загрузка агента (0-100)
- `success_rate` - процент успешно выполненных задач
- `total_tasks_completed` - количество выполненных задач
- `total_tasks_failed` - количество проваленных задач
- `average_completion_time` - среднее время выполнения
- `specialization_tags` - специализации агента
- `performance_metrics` - детальные метрики производительности
- `heartbeat_interval` - интервал heartbeat (сек)
- `max_concurrent_tasks` - макс. количество одновременных задач
- `current_task_count` - текущее количество задач

### AgentTask (расширен)
Новые поля:
- `retry_count` - количество попыток
- `max_retries` - максимум попыток
- `dependencies` - зависимости от других задач
- `verification_status` - статус верификации
- `verification_details` - детали верификации
- `assigned_strategy` - стратегия назначения
- `execution_context` - контекст выполнения
- `quality_score` - оценка качества
- `reviewed_by_agent_ids` - ID агентов-ревьюеров

### AgentCollaboration (новая модель)
Представляет коллаборацию между агентами:
- `agent_task` - задача
- `primary_agent` - основной агент
- `collaboration_type` - тип коллаборации
- `status` - статус
- `participating_agent_ids` - участвующие агенты
- `consensus_results` - результаты консенсуса
- `collaboration_metadata` - метаданные

### OrchestratorEvent (новая модель)
Логирование событий оркестратора:
- `event_type` - тип события
- `agent` - связанный агент
- `agent_task` - связанная задача
- `severity` - серьезность (info/warning/error/critical)
- `event_data` - данные события
- `message` - сообщение
- `occurred_at` - время события

## Примеры использования

### Пример 1: Простое выполнение задачи

```ruby
# Регистрируем агента
agent = Orchestration::AgentRegistry.register(
  agent_type: "Agents::AnalyzerAgent",
  name: "Data Analyzer",
  capabilities: { data_analysis: true }
)

# Добавляем задачу
task = Orchestration::TaskQueueManager.enqueue(
  task_type: "data_analysis",
  input_data: { data: [1, 2, 3, 4, 5] },
  priority: 5
)

# Назначаем и выполняем
assignment = Orchestration::TaskQueueManager.assign_task(task.id)
result = Orchestration::Orchestrator.execute_task(
  assignment[:task],
  assignment[:agent]
)

# Результат автоматически верифицируется
puts result[:verification]
```

### Пример 2: Задача с peer review

```ruby
# Создаем задачу
task = Orchestration::TaskQueueManager.enqueue(
  task_type: "complex_analysis",
  input_data: { dataset: "critical_data.csv" },
  priority: 10
)

# Выполняем
assignment = Orchestration::TaskQueueManager.assign_task(task.id)
Orchestration::Orchestrator.execute_task(assignment[:task], assignment[:agent])

# Запрашиваем peer review
review = Orchestration::VerificationLayer.request_peer_review(
  task.id,
  reviewer_count: 3
)

# Ждем результатов и консенсуса
# (выполняется асинхронно через AgentReviewJob)
```

### Пример 3: Consensus задача

```ruby
# Создаем consensus задачу
result = Orchestration::ConsensusMechanism.create_consensus_task(
  task_type: "critical_decision",
  input_data: { scenario: "..." },
  required_agents: 5,
  consensus_threshold: 0.8
)

# Выполняем
execution = Orchestration::ConsensusMechanism.execute_consensus_task(
  result[:collaboration].id
)

# Проверяем консенсус
if execution[:consensus][:consensus_reached]
  puts "Consensus reached: #{execution[:consensus][:consensus_result]}"
else
  puts "No consensus reached"
end
```

### Пример 4: Мониторинг системы

```ruby
# Проверка здоровья
health = Orchestration::Orchestrator.health_check

if health[:status] == "critical"
  # Масштабируем агентов
  Orchestration::Orchestrator.scale_agents(
    agent_type: "Agents::AnalyzerAgent",
    target_count: health[:agents][:total_agents] + 3
  )
end

# Оптимизация
Orchestration::Orchestrator.optimize

# Статистика за последние 24 часа
stats = Orchestration::Orchestrator.statistics(since: 24.hours.ago)
puts "Completed tasks: #{stats[:tasks][:completed]}"
puts "Average success rate: #{stats[:agents][:average_success_rate]}%"
```

## Мониторинг и логирование

Все события оркестратора логируются в таблицу `orchestrator_events`:

```ruby
# Получить последние события
events = OrchestratorEvent.recent.limit(50)

# События по типу
errors = OrchestratorEvent.errors

# События для агента
agent_events = OrchestratorEvent.for_agent(agent.id)

# Здоровье системы
health = OrchestratorEvent.system_health(since: 1.hour.ago)
# => {
#   total_events: 245,
#   critical_count: 0,
#   error_count: 2,
#   warning_count: 15,
#   recent_errors: [...]
# }
```

## Интеграция с существующими агентами

Система автоматически работает с существующими агентами A2D2:
- `Agents::AnalyzerAgent`
- `Agents::ValidatorAgent`
- `Agents::TransformerAgent`
- `Agents::ReporterAgent`
- `Agents::IntegrationAgent`

Каждый агент автоматически получает возможности оркестрации.

## Конфигурация

В `config/initializers/orchestration.rb`:

```ruby
# Конфигурация оркестратора
Rails.application.config.after_initialize do
  # Запуск оркестратора при старте приложения
  Orchestration::Orchestrator.start if Rails.env.production?
end
```

## Требования

- Ruby 3.3.6+
- Rails 8.1.0+
- Solid Queue (встроено в Rails 8)
- PostgreSQL или SQLite3

## Производительность

- Система поддерживает **неограниченное** количество агентов
- Обработка **сотен задач в минуту**
- Автоматическая балансировка нагрузки
- Горизонтальное масштабирование через добавление агентов

## Будущие улучшения

- [ ] Machine Learning для прогнозирования нагрузки
- [ ] Автоматическое масштабирование на основе метрик
- [ ] Dashboard для визуализации оркестрации
- [ ] WebSocket API для real-time мониторинга
- [ ] Интеграция с внешними системами мониторинга (Prometheus, Grafana)

## Ссылки

- [Hive Mind](https://github.com/konard/hive-mind) - источник концепций
- [A2D2 Documentation](../README.md) - основная документация
- [Agent Development Guide](./AGENT_DEVELOPMENT.md) - разработка агентов
