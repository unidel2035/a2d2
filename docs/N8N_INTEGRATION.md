# N8nDD Integration Documentation

## Обзор

A2D2 теперь интегрирован с концепциями и интерфейсами n8nDD - популярной платформы автоматизации рабочих процессов. Эта интеграция позволяет:

- Импортировать и экспортировать workflows в формате n8n
- Выполнять n8n-совместимые рабочие процессы
- Использовать node-based архитектуру для построения автоматизаций
- Интегрировать AI-агентов A2D2 в workflow-процессы

## Архитектура

### Основные компоненты

1. **Workflow** - Основная модель рабочего процесса
   - Содержит узлы (nodes) и соединения (connections)
   - Поддерживает статусы: active, inactive, error
   - Экспорт/импорт в формате n8n

2. **WorkflowNode** - Узел рабочего процесса
   - Различные типы: trigger, http_request, ai_agent, transform, и др.
   - Хранит параметры и креденшиалы
   - Позиционирование для визуального редактора

3. **WorkflowConnection** - Соединение между узлами
   - Связывает source и target узлы
   - Поддерживает множественные входы/выходы
   - Типы соединений: main, error, etc.

4. **WorkflowExecution** - Выполнение рабочего процесса
   - Отслеживание статуса: new, running, success, error
   - Хранение входных/выходных данных
   - Метрики выполнения

### Node Types (Типы узлов)

#### 1. Trigger Node
Точка входа в workflow. Запускает выполнение процесса.

```ruby
{
  name: 'Manual Trigger',
  type: 'trigger',
  parameters: {
    triggerType: 'manual'
  }
}
```

#### 2. HTTP Request Node
Выполнение HTTP-запросов к внешним API.

```ruby
{
  name: 'API Call',
  type: 'http_request',
  parameters: {
    url: 'https://api.example.com/data',
    method: 'GET',
    headers: {
      'Authorization': 'Bearer {{$json.token}}'
    }
  }
}
```

#### 3. AI Agent Node
Интеграция с AI-агентами A2D2.

```ruby
{
  name: 'Analyze Data',
  type: 'ai_agent',
  parameters: {
    agentType: 'analyzer',
    task: 'Analyze the customer data',
    config: {}
  }
}
```

Поддерживаемые типы агентов:
- `analyzer` - Анализ данных
- `transformer` - Трансформация данных
- `validator` - Валидация данных
- `reporter` - Генерация отчетов
- `integration` - Интеграция с внешними системами

#### 4. Transform Node
Трансформация и преобразование данных.

```ruby
{
  name: 'Filter Results',
  type: 'transform',
  parameters: {
    transformationType: 'filter',
    operations: [
      {
        field: 'status',
        operator: 'equals',
        value: 'active'
      }
    ]
  }
}
```

#### 5. Set Node
Установка значений в данных.

```ruby
{
  name: 'Add Timestamp',
  type: 'set',
  parameters: {
    mode: 'set',
    values: [
      {
        field: 'timestamp',
        value: '{{$now}}'
      }
    ]
  }
}
```

#### 6. If Node
Условная логика.

```ruby
{
  name: 'Check Status',
  type: 'if',
  parameters: {
    conditions: [
      {
        field: 'amount',
        operator: 'greater_than',
        value: 1000
      }
    ],
    conditionLogic: 'and'
  }
}
```

#### 7. Switch Node
Маршрутизация данных по условиям.

```ruby
{
  name: 'Route by Type',
  type: 'switch',
  parameters: {
    rules: [
      {
        conditions: [{ field: 'type', operator: 'equals', value: 'order' }],
        output: 'orders'
      },
      {
        conditions: [{ field: 'type', operator: 'equals', value: 'invoice' }],
        output: 'invoices'
      }
    ],
    defaultOutput: 'other'
  }
}
```

#### 8. Code Node
Выполнение произвольного Ruby-кода.

```ruby
{
  name: 'Custom Logic',
  type: 'code',
  parameters: {
    language: 'ruby',
    code: <<~RUBY
      # Input data available as @input
      result = @input['items'].select { |item| item['price'] > 100 }
      output({ filtered_items: result })
    RUBY
  }
}
```

## API Endpoints

### Workflow Management

#### List all workflows
```http
GET /workflows
```

Response:
```json
{
  "workflows": [
    {
      "id": "1",
      "name": "Customer Onboarding",
      "active": true,
      "nodes": [...],
      "connections": [...],
      "createdAt": "2025-10-28T10:00:00Z"
    }
  ],
  "total": 1
}
```

#### Get single workflow
```http
GET /workflows/:id
```

#### Create workflow
```http
POST /workflows
Content-Type: application/json

{
  "workflow": {
    "name": "New Workflow",
    "status": "inactive",
    "n8n_data": {
      "name": "New Workflow",
      "nodes": [...],
      "connections": [...]
    }
  }
}
```

#### Execute workflow
```http
POST /workflows/:id/execute
Content-Type: application/json

{
  "mode": "manual",
  "input_data": {
    "customer_id": 123,
    "action": "process"
  }
}
```

Response:
```json
{
  "execution_id": "456",
  "status": "running",
  "started_at": "2025-10-28T10:05:00Z"
}
```

#### Activate/Deactivate workflow
```http
POST /workflows/:id/activate
POST /workflows/:id/deactivate
```

### Templates

#### List available templates
```http
GET /workflows/templates
```

Response:
```json
{
  "templates": [
    { "type": "simple_http", "name": "Simple HTTP Request" },
    { "type": "ai_agent_pipeline", "name": "AI Agent Pipeline" },
    { "type": "data_transformation", "name": "Data Transformation" }
  ]
}
```

#### Create workflow from template
```http
POST /workflows/from_template
Content-Type: application/json

{
  "template_type": "ai_agent_pipeline"
}
```

### N8n Integration API

#### Import n8n workflow
```http
POST /api/v1/n8n/import
Content-Type: application/json

{
  "workflow": {
    "name": "Imported Workflow",
    "nodes": [...],
    "connections": [...]
  }
}
```

#### Export workflow in n8n format
```http
GET /api/v1/n8n/export/:id
```

#### Validate n8n workflow
```http
POST /api/v1/n8n/validate
Content-Type: application/json

{
  "workflow": {
    "name": "Test Workflow",
    "nodes": [...]
  }
}
```

Response:
```json
{
  "valid": true,
  "errors": []
}
```

## Expression System

A2D2 поддерживает упрощенную систему выражений, аналогичную n8n:

### Доступ к данным
```ruby
{{$json.field}}           # Доступ к полю в текущих данных
{{$json.nested.field}}    # Доступ к вложенному полю
{{$json.items[0]}}        # Доступ к элементу массива
```

### Специальные переменные
```ruby
{{$now}}                  # Текущее время
```

### Примеры использования

В HTTP Request Node:
```ruby
{
  url: 'https://api.example.com/users/{{$json.user_id}}',
  headers: {
    'Authorization': 'Bearer {{$json.token}}'
  }
}
```

В Set Node:
```ruby
{
  values: [
    {
      field: 'full_name',
      value: '{{$json.first_name}} {{$json.last_name}}'
    }
  ]
}
```

## Integration with A2D2 Agents

N8n workflows можно интегрировать с существующей системой AI-агентов A2D2:

```ruby
workflow = Workflow.create!(name: 'Agent Pipeline')

# Trigger node
trigger = workflow.workflow_nodes.create!(
  name: 'Start',
  node_type: 'trigger',
  position: [100, 100]
)

# AI Agent node
analyzer = workflow.workflow_nodes.create!(
  name: 'Analyze Document',
  node_type: 'ai_agent',
  position: [300, 100],
  parameters: {
    agentType: 'analyzer',
    task: 'Extract key information from document'
  }
)

# Connect nodes
workflow.workflow_connections.create!(
  source_node: trigger,
  target_node: analyzer
)

# Execute
execution = workflow.execute(input_data: { document_id: 123 })
```

## Converting Existing Processes

Существующие Process из A2D2 можно конвертировать в Workflows:

```ruby
service = N8nIntegrationService.new
workflow = service.convert_process_to_workflow(process_id: 1)

# Workflow теперь содержит все шаги из Process
workflow.workflow_nodes.each do |node|
  puts "Node: #{node.name} (#{node.node_type})"
end
```

## Database Schema

### workflows table
```ruby
create_table :workflows do |t|
  t.string :name, null: false
  t.string :status, default: 'inactive'
  t.text :settings        # JSON
  t.text :static_data     # JSON
  t.text :tags            # JSON
  t.references :user
  t.references :project
  t.timestamps
end
```

### workflow_nodes table
```ruby
create_table :workflow_nodes do |t|
  t.references :workflow, null: false
  t.string :name, null: false
  t.string :node_type, null: false
  t.integer :type_version, default: 1
  t.text :position        # JSON array [x, y]
  t.text :parameters      # JSON
  t.text :credentials     # JSON
  t.timestamps
end
```

### workflow_connections table
```ruby
create_table :workflow_connections do |t|
  t.references :workflow, null: false
  t.references :source_node, null: false
  t.references :target_node, null: false
  t.integer :source_output_index, default: 0
  t.integer :target_input_index, default: 0
  t.string :connection_type, default: 'main'
  t.timestamps
end
```

### workflow_executions table
```ruby
create_table :workflow_executions do |t|
  t.references :workflow, null: false
  t.string :status, null: false, default: 'new'
  t.string :mode
  t.datetime :started_at
  t.datetime :stopped_at
  t.datetime :finished_at
  t.text :data            # JSON
  t.text :error_message
  t.timestamps
end
```

## Example: Complete Workflow

```ruby
# Create workflow
workflow = Workflow.create!(
  name: 'Customer Data Processing',
  status: 'active'
)

# 1. Trigger
trigger = workflow.workflow_nodes.create!(
  name: 'Manual Trigger',
  node_type: 'trigger',
  position: [100, 100],
  parameters: { triggerType: 'manual' }
)

# 2. HTTP Request - fetch customer data
http = workflow.workflow_nodes.create!(
  name: 'Fetch Customer',
  node_type: 'http_request',
  position: [300, 100],
  parameters: {
    url: 'https://api.example.com/customers/{{$json.customer_id}}',
    method: 'GET'
  }
)

# 3. AI Agent - analyze customer data
analyzer = workflow.workflow_nodes.create!(
  name: 'Analyze Customer',
  node_type: 'ai_agent',
  position: [500, 100],
  parameters: {
    agentType: 'analyzer',
    task: 'Analyze customer behavior and risk profile'
  }
)

# 4. If - check risk level
if_node = workflow.workflow_nodes.create!(
  name: 'Check Risk',
  node_type: 'if',
  position: [700, 100],
  parameters: {
    conditions: [
      { field: 'risk_score', operator: 'greater_than', value: 70 }
    ]
  }
)

# 5a. High risk path - send alert
alert = workflow.workflow_nodes.create!(
  name: 'Send Alert',
  node_type: 'http_request',
  position: [900, 50],
  parameters: {
    url: 'https://api.example.com/alerts',
    method: 'POST',
    body: { customer_id: '{{$json.customer_id}}', alert_type: 'high_risk' }
  }
)

# 5b. Low risk path - standard processing
process = workflow.workflow_nodes.create!(
  name: 'Standard Processing',
  node_type: 'ai_agent',
  position: [900, 150],
  parameters: {
    agentType: 'transformer',
    task: 'Process customer onboarding'
  }
)

# Create connections
[
  [trigger, http],
  [http, analyzer],
  [analyzer, if_node],
  [if_node, alert],      # true branch
  [if_node, process]     # false branch
].each do |source, target|
  workflow.workflow_connections.create!(
    source_node: source,
    target_node: target
  )
end

# Execute workflow
execution = workflow.execute(
  input_data: { customer_id: 12345 }
)

# Check status
puts execution.status  # => "running"

# Wait for completion and check result
sleep 5
execution.reload
puts execution.status  # => "success" or "error"
puts execution.data    # => { input: {...}, output: {...} }
```

## Testing

Example test:

```ruby
# test/models/workflow_test.rb
require 'test_helper'

class WorkflowTest < ActiveSupport::TestCase
  test 'should create workflow from n8n format' do
    n8n_data = {
      name: 'Test Workflow',
      nodes: [
        {
          name: 'Start',
          type: 'trigger',
          typeVersion: 1,
          position: [100, 100],
          parameters: {}
        }
      ],
      connections: []
    }

    workflow = Workflow.from_n8n_format(n8n_data)

    assert workflow.persisted?
    assert_equal 'Test Workflow', workflow.name
    assert_equal 1, workflow.workflow_nodes.count
  end

  test 'should execute workflow' do
    workflow = workflows(:simple_workflow)
    execution = workflow.execute(input_data: { test: 'data' })

    assert execution.persisted?
    assert_equal 'running', execution.status
  end
end
```

## Best Practices

1. **Модульность**: Создавайте переиспользуемые workflows для общих задач
2. **Обработка ошибок**: Всегда добавляйте error handling nodes
3. **Тестирование**: Тестируйте workflows с различными входными данными
4. **Мониторинг**: Отслеживайте статус выполнений через WorkflowExecution
5. **Безопасность**: Используйте credentials для чувствительных данных
6. **Производительность**: Избегайте слишком глубокой вложенности узлов

## Future Enhancements

- [ ] Визуальный редактор workflows (frontend)
- [ ] Webhook triggers
- [ ] Scheduled execution (cron)
- [ ] Real-time execution monitoring
- [ ] Workflow versioning
- [ ] More node types (Email, Database, etc.)
- [ ] Advanced expression evaluator
- [ ] Workflow marketplace
- [ ] External n8n instance sync
- [ ] Performance metrics and analytics

## Support

Для вопросов и поддержки:
- GitHub Issues: https://github.com/unidel2035/a2d2/issues
- GitHub Discussions: https://github.com/unidel2035/a2d2/discussions

## References

- n8nDD Repository: https://github.com/unidel2035/n8nDD
- Original n8n Documentation: https://docs.n8n.io
- A2D2 Main README: ../README.md
