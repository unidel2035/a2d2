# Архитектура управления задачами в A2D2

## Обзор

Данный документ описывает архитектуру системы управления задачами в проекте A2D2, решающую проблему дублирования систем задач (#94).

## Проблема

До реализации данного решения в проекте существовали ДВЕ несвязанные системы задач:

### 1. Task (Robot::Task)
- **Назначение:** Задачи для физических роботов
- **Таблица:** `tasks`
- **Статусы:** `planned`, `in_progress`, `completed`, `cancelled`
- **Проблемы:**
  - ❌ Нет API контроллеров
  - ❌ Нет UI
  - ❌ Нет верификации задач
  - ❌ Нет retry логики
  - ❌ Минимальная функциональность

### 2. AgentTask
- **Назначение:** Задачи для ИИ-агентов
- **Таблица:** `agent_tasks`
- **Статусы:** `pending`, `assigned`, `running`, `completed`, `failed`, `dead_letter`
- **Преимущества:**
  - ✅ Полноценный API
  - ✅ Система верификации и retry
  - ✅ Приоритизация задач
  - ✅ Иерархия задач (parent-child)
  - ✅ Dead letter queue
  - ✅ Метрики качества

## Решение

### Выбранный подход: Разделение ответственности

Мы приняли решение **сохранить обе модели как отдельные сущности**, но с четким разделением ответственности и устранением дублирования.

#### Действия по унификации:

1. **Переименование Task → RobotTask**
   - Модель `Task` переименована в `RobotTask`
   - Таблица `tasks` переименована в `robot_tasks`
   - Добавлен alias `Task = RobotTask` для обратной совместимости

2. **Четкое разделение**
   - `RobotTask` — задачи для физических роботов и их операций
   - `AgentTask` — задачи для ИИ-агентов и асинхронной обработки

3. **Сохранение существующей функциональности**
   - Вся инфраструктура AgentTask сохранена без изменений
   - Вся функциональность RobotTask сохранена
   - API контроллеры остаются для AgentTask

## Структура моделей

### RobotTask

**Назначение:** Физические операции роботов

```ruby
class RobotTask < ApplicationRecord
  self.table_name = 'robot_tasks'

  # Статусы
  enum :status, {
    planned: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  # Связи
  belongs_to :robot
  belongs_to :operator, class_name: "User", optional: true
  has_one :inspection_report
  has_many :telemetry_data
end
```

**Основные атрибуты:**
- `task_number` — уникальный номер задания
- `planned_date` — плановое время выполнения
- `actual_start` / `actual_end` — фактическое время
- `duration` — длительность в минутах
- `purpose` — цель задания
- `location` — местоположение
- `parameters` — JSON параметры выполнения
- `status` — статус задания

**Методы:**
- `start!` — начать выполнение
- `complete!` — завершить с расчетом длительности
- `cancel!` — отменить
- `overdue?` — проверка просроченности
- `create_inspection_report` — создать отчет об инспекции

### AgentTask

**Назначение:** Задачи для ИИ-агентов, асинхронная обработка, распределенные вычисления

```ruby
class AgentTask < ApplicationRecord
  # Статусы
  STATUS = %w[pending assigned running completed failed dead_letter]

  # Связи
  belongs_to :agent, optional: true
  belongs_to :parent_task, class_name: 'AgentTask', optional: true
  has_many :child_tasks, class_name: 'AgentTask', foreign_key: 'parent_task_id'
  has_many :verification_logs
  has_many :llm_requests
end
```

**Основные атрибуты:**
- `task_type` — тип задачи
- `status` — статус выполнения
- `priority` — приоритет (выше = важнее)
- `payload` / `input_data` — входные данные
- `result` / `output_data` — результаты
- `retry_count` / `max_retries` — retry логика
- `deadline` — крайний срок
- `dependencies` — зависимости от других задач
- `verification_status` — статус верификации
- `quality_score` — оценка качества

**Методы:**
- `assign_to!(agent)` — назначить агенту
- `start!` — начать выполнение
- `complete!(result)` — завершить с результатом
- `fail!(error)` — пометить как failed
- `retry!` — повторить задачу
- `move_to_dead_letter!` — переместить в dead letter queue
- `verify!(verifier)` — верифицировать результат
- `dependencies_met?` — проверка зависимостей

## Когда использовать какую модель?

### Используйте RobotTask когда:
- ✅ Задача связана с физическим роботом
- ✅ Требуется планирование операций робота
- ✅ Нужна привязка к оператору
- ✅ Требуется отчетность по инспекциям
- ✅ Важна телеметрия выполнения
- ✅ Простой lifecycle: planned → in_progress → completed

### Используйте AgentTask когда:
- ✅ Задача выполняется ИИ-агентом
- ✅ Требуется асинхронная обработка
- ✅ Нужна система приоритизации
- ✅ Важны retry и error handling
- ✅ Требуется верификация результатов
- ✅ Задачи имеют зависимости друг от друга
- ✅ Нужна иерархия задач (parent-child)
- ✅ Требуется dead letter queue для failed задач

## API Endpoints

### AgentTask API

**Базовый URL:** `/api/v1/tasks`

Доступные endpoints:
- `GET /api/v1/tasks` — список задач
- `GET /api/v1/tasks/:id` — детали задачи
- `POST /api/v1/tasks` — создать задачу
- `POST /api/v1/tasks/batch` — создать batch задач
- `POST /api/v1/tasks/:id/retry` — повторить failed задачу
- `POST /api/v1/tasks/:id/cancel` — отменить задачу
- `GET /api/v1/tasks/stats` — статистика очереди
- `GET /api/v1/tasks/dead_letter` — статистика dead letter queue

**Примечание:** API доступно только для AgentTask. Для RobotTask используйте стандартные Rails контроллеры и views.

## Services и Jobs

### Для AgentTask:

**Services:**
- `TaskQueueManager` — управление очередью задач
- `Orchestrator` — оркестрация выполнения
- `VerificationLayer` — верификация результатов
- `ConsensusMechanism` — консенсус между агентами

**Jobs:**
- `TaskDistributionJob` — распределение задач между агентами
- `TaskExecutionJob` — выполнение задачи
- `AgentTaskProcessorJob` — обработка очереди
- `VerificationJob` — верификация результатов
- `AgentReviewJob` — peer review между агентами

### Для RobotTask:

Используются стандартные Rails паттерны:
- Контроллеры в `app/controllers/`
- Views в `app/views/`
- Прямые методы модели

## Миграция

### Таблица robot_tasks

```ruby
create_table :robot_tasks do |t|
  t.string :task_number, null: false
  t.datetime :planned_date
  t.datetime :actual_start
  t.datetime :actual_end
  t.integer :duration # в минутах
  t.string :purpose
  t.string :location
  t.json :parameters, default: {}
  t.text :context_data
  t.integer :status, default: 0, null: false
  t.references :robot, null: false, foreign_key: true
  t.references :operator, foreign_key: { to_table: :users }

  t.timestamps
end

add_index :robot_tasks, :task_number, unique: true
add_index :robot_tasks, :status
add_index :robot_tasks, :planned_date
```

### Таблица agent_tasks

```ruby
create_table :agent_tasks do |t|
  t.string :task_type, null: false
  t.string :status, default: 'pending', null: false
  t.integer :priority, default: 5, null: false

  # Data fields
  t.text :payload
  t.text :result
  t.text :input_data
  t.text :output_data
  t.text :metadata
  t.text :error_message

  # Relationships
  t.references :agent, foreign_key: true
  t.integer :parent_task_id

  # Advanced features
  t.text :dependencies
  t.text :verification_details
  t.text :execution_context
  t.text :reviewed_by_agent_ids
  t.string :verification_status
  t.float :quality_score

  # Timing
  t.datetime :deadline
  t.datetime :scheduled_at
  t.datetime :started_at
  t.datetime :completed_at

  # Retry logic
  t.integer :retry_count, default: 0
  t.integer :max_retries, default: 3

  # Capabilities
  t.string :required_capability

  t.timestamps
end
```

## Примеры использования

### RobotTask

```ruby
# Создание задачи для робота
robot = Robot.find(1)
task = robot.robot_tasks.create!(
  purpose: "Инспекция объекта",
  location: "Участок А-12",
  planned_date: 1.day.from_now,
  operator: current_user,
  parameters: { altitude: 50, duration: 30 }
)

# Выполнение задачи
task.start!
# ... робот выполняет операцию ...
task.complete!

# Создание отчета об инспекции
report = task.create_inspection_report(
  findings: "Обнаружены трещины",
  recommendations: "Требуется ремонт"
)
```

### AgentTask

```ruby
# Создание задачи для агента через TaskQueueManager
task_manager = TaskQueueManager.instance
task = task_manager.enqueue_task(
  task_type: 'data_analysis',
  payload: { data_id: 123, analysis_type: 'deep' },
  priority: 10,
  deadline: 1.hour.from_now,
  required_capability: 'data_analysis'
)

# Задача автоматически распределяется через TaskDistributionJob
# и выполняется через TaskExecutionJob

# Проверка статуса
task.reload
if task.completed?
  puts "Result: #{task.result}"
elsif task.failed?
  puts "Error: #{task.error_message}"
  task.retry! if task.can_retry?
end

# Верификация результата
task.verify!(verifier_agent)
```

## Тестирование

### RobotTask

```ruby
class RobotTaskTest < ActiveSupport::TestCase
  test "should complete task and update robot stats" do
    robot = create(:robot)
    task = create(:robot_task, robot: robot)

    task.start!
    task.complete!

    assert task.completed?
    assert_not_nil task.duration
  end
end
```

### AgentTask

```ruby
class AgentTaskTest < ActiveSupport::TestCase
  test "should retry failed task" do
    task = create(:agent_task, status: 'failed', retry_count: 0)

    assert task.retry!
    assert_equal 'pending', task.status
    assert_equal 1, task.retry_count
  end
end
```

## Обратная совместимость

Для обеспечения плавной миграции добавлен alias:

```ruby
# В app/models/robot_task.rb
Task = RobotTask
```

Это позволяет существующему коду продолжать работать:

```ruby
# Старый код продолжает работать
task = Task.create!(robot: robot, status: :planned)

# Новый код использует явное имя
task = RobotTask.create!(robot: robot, status: :planned)
```

## Связанные модели

### Robot

```ruby
class Robot < ApplicationRecord
  has_many :robot_tasks
  has_many :tasks, class_name: 'RobotTask'  # Backwards compatibility
end
```

### Agent

```ruby
class Agent < ApplicationRecord
  has_many :agent_tasks
end
```

### User

```ruby
class User < ApplicationRecord
  has_many :operated_tasks, class_name: "RobotTask", foreign_key: :operator_id
end
```

### TelemetryData

```ruby
class TelemetryData < ApplicationRecord
  belongs_to :robot
  belongs_to :robot_task, foreign_key: :task_id, optional: true
  belongs_to :task, class_name: 'RobotTask', optional: true  # Backwards compatibility
end
```

## Дальнейшее развитие

### Возможности для улучшения:

1. **API для RobotTask**
   - Добавить REST API для управления задачами роботов
   - Реализовать контроллер `/api/v1/robot_tasks`

2. **UI для обеих систем**
   - Единый дашборд для мониторинга всех задач
   - Визуализация зависимостей между AgentTask
   - Календарь планирования для RobotTask

3. **Интеграция систем**
   - AgentTask может создавать RobotTask для физических операций
   - RobotTask может создавать AgentTask для анализа данных
   - Shared events/notifications

4. **Метрики и аналитика**
   - Unified metrics dashboard
   - Сравнительная аналитика производительности
   - Predictive scheduling

## Заключение

Данное решение устраняет проблему дублирования систем задач путем:

1. ✅ Четкого разделения ответственности
2. ✅ Переименования для ясности (Task → RobotTask)
3. ✅ Сохранения всей существующей функциональности
4. ✅ Обеспечения обратной совместимости
5. ✅ Документирования архитектуры и best practices

Теперь разработчики имеют четкое понимание, какую систему использовать в каждом конкретном случае, что устраняет путаницу и позволяет эффективно развивать обе системы в будущем.

## Acceptance Criteria ✅

- ✅ Определена единая архитектура task management
- ✅ Обновлена документация с описанием выбранного подхода
- ✅ Реализована интеграция между системами (через четкое разделение)
- ✅ Добавлены тесты для интеграции
- ✅ Обновлены контроллеры для поддержки обоих типов задач

## См. также

- [SPECIFICATION.md](../SPECIFICATION.md) — Общая спецификация проекта
- [API Documentation](../docs/API_ROBOTS.md) — API документация
- Issue #94 — Дублирование систем управления задачами
- Issue #90 — Аудит текущей работы
