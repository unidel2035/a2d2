# SR-003: Требования к интерфейсам системы A2D2

## Документ системных требований (SRD)
**Версия**: 1.0
**Дата**: 28 октября 2025
**Статус**: Утверждено

---

## 1. Введение

Данный документ определяет все интерфейсы взаимодействия компонентов системы A2D2:
- **User Interfaces**: Web, API
- **System Interfaces**: Internal communications
- **External Interfaces**: Third-party integrations

---

## 2. Web User Interface (UI)

### IRQ-WEB-001: Главная страница (Dashboard)

**Назначение**: Обзор текущего состояния системы

**Компоненты**:
- Статистика агентов (активные, в ошибке, неактивные)
- Граф очереди задач (размер, время ожидания)
- Последние события и алерты
- Быстрые действия (создать задачу, перезагрузить агента)

**Интерактивные элементы**:
- Фильтры (дата, тип события, приоритет)
- Обновление в реальном времени (WebSocket)
- Export в PDF

---

### IRQ-WEB-002: Управление агентами

**Путь**: `/agents`

**Функционал**:
- Таблица всех агентов с сортировкой и фильтрацией
- Поиск по имени, типу, статусу
- View детальной информации о агенте
- Управление (стартовать, остановить, удалить)
- Логи и метрики агента

---

### IRQ-WEB-003: Управление задачами

**Путь**: `/tasks`

**Функционал**:
- Список задач с фильтрацией (статус, дата, агент)
- Создание новой задачи
- View прогресса и результатов
- Логи выполнения

---

### IRQ-WEB-004: Аналитика и отчетность

**Путь**: `/analytics`

**Функционал**:
- Графики производительности
- Сравнение агентов
- Тренды по времени
- Экспорт отчетов

---

## 3. REST API

### IRQ-API-001: Эндпоинты управления агентами

```
GET /api/v1/agents
  Параметры: page, per_page, filter[status], filter[type]
  Response: 200 OK
  {
    "data": [
      {
        "id": "uuid",
        "name": "string",
        "type": "analyzer|transformer|validator|reporter|integration",
        "status": "active|inactive|error",
        "created_at": "ISO8601",
        "capabilities": ["string"]
      }
    ],
    "meta": {
      "total": 100,
      "page": 1,
      "per_page": 10
    }
  }

GET /api/v1/agents/{id}
  Response: 200 OK с детальной информацией

POST /api/v1/agents
  Body: { "name": "...", "type": "...", "config": {...} }
  Response: 201 Created

PATCH /api/v1/agents/{id}
  Body: { "status": "...", "config": {...} }
  Response: 200 OK

DELETE /api/v1/agents/{id}
  Response: 204 No Content

POST /api/v1/agents/{id}/restart
  Response: 202 Accepted
```

---

### IRQ-API-002: Эндпоинты управления задачами

```
GET /api/v1/tasks
  Параметры: page, per_page, filter[status], filter[agent_id]
  Response: 200 OK (список задач)

GET /api/v1/tasks/{id}
  Response: 200 OK (детали задачи)

POST /api/v1/tasks
  Body: {
    "title": "string",
    "agent_id": "uuid",
    "parameters": {},
    "priority": 1-10,
    "deadline": "ISO8601"
  }
  Response: 201 Created

PATCH /api/v1/tasks/{id}
  Body: { "status": "...", "parameters": {...} }
  Response: 200 OK

DELETE /api/v1/tasks/{id}
  Response: 204 No Content

POST /api/v1/tasks/{id}/retry
  Response: 202 Accepted
```

---

### IRQ-API-003: Аутентификация и авторизация

```
POST /api/v1/auth/login
  Body: { "email": "...", "password": "..." }
  Response: 200 OK
  {
    "token": "jwt_token",
    "expires_at": "ISO8601"
  }

POST /api/v1/auth/logout
  Authorization: Bearer token
  Response: 200 OK

POST /api/v1/auth/refresh
  Body: { "token": "current_token" }
  Response: 200 OK { "token": "new_token" }
```

---

## 4. WebSocket Interface

### IRQ-WS-001: Real-time обновления

**Путь**: `ws://domain/cable`

**Каналы**:

1. **agents_status**
   ```json
   {
     "type": "agent_status_changed",
     "agent_id": "uuid",
     "status": "active|inactive|error",
     "timestamp": "ISO8601"
   }
   ```

2. **task_progress**
   ```json
   {
     "type": "task_progress",
     "task_id": "uuid",
     "progress": 0-100,
     "message": "string",
     "timestamp": "ISO8601"
   }
   ```

3. **system_alerts**
   ```json
   {
     "type": "alert",
     "level": "info|warning|error|critical",
     "message": "string",
     "timestamp": "ISO8601"
   }
   ```

---

## 5. Internal System Interfaces

### IRQ-SYS-001: Интерфейс Orchestrator-Agent

**Message Format**: JSON

**Messages**:

1. **Task Assignment**
   ```json
   {
     "type": "assign_task",
     "task_id": "uuid",
     "task_type": "string",
     "parameters": {},
     "deadline": "ISO8601"
   }
   ```

2. **Task Completion**
   ```json
   {
     "type": "task_completed",
     "task_id": "uuid",
     "result": {},
     "execution_time_ms": 1000
   }
   ```

3. **Heartbeat**
   ```json
   {
     "type": "heartbeat",
     "agent_id": "uuid",
     "status": "idle|working|error",
     "tasks_completed": 100,
     "last_update": "ISO8601"
   }
   ```

---

### IRQ-SYS-002: Интерфейс задача-результат

**Storage Interface**:
```
save_result(task_id, result, metadata)
get_result(task_id)
update_result(task_id, partial_result)
```

---

### IRQ-SYS-003: Интерфейс очереди задач

**Queue Interface**:
```
enqueue(task)         # Добавить в очередь
dequeue()             # Получить следующую задачу
prioritize(task_id)   # Переместить вперед
cancel(task_id)       # Отменить задачу
get_queue_status()    # Статистика очереди
```

---

## 6. External System Interfaces

### IRQ-EXT-001: LLM Providers Integration

**Поддерживаемые провайдеры**:
- OpenAI API
- Anthropic Claude API
- Google Gemini API
- DeepSeek API

**Единый интерфейс**:
```
call_llm(provider, model, prompt, parameters)
  Returns: {
    "result": "string",
    "tokens_used": 100,
    "cost": 0.001
  }
```

---

### IRQ-EXT-002: Database Interface

**Поддерживаемые БД**:
- PostgreSQL
- MySQL
- SQLite (разработка)

**Query Interface**:
```
execute_query(database_url, query, parameters)
  Returns: Result set or update count
```

---

### IRQ-EXT-003: File Storage Interface

**Поддерживаемые хранилища**:
- Local filesystem
- AWS S3
- Azure Blob Storage
- Google Cloud Storage

**File Operations**:
```
upload_file(path, file_content)
download_file(path)
delete_file(path)
list_files(directory)
```

---

## 7. Error Response Format

**Стандартный формат ошибки**:
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {
      "field": "error_message"
    },
    "timestamp": "ISO8601",
    "request_id": "uuid"
  }
}
```

**HTTP Status codes**:
- 200 OK - Успешно
- 201 Created - Создано
- 202 Accepted - Принято к обработке
- 204 No Content - Успешно, нет контента
- 400 Bad Request - Ошибка в запросе
- 401 Unauthorized - Не аутентифицирован
- 403 Forbidden - Доступ запрещен
- 404 Not Found - Не найдено
- 409 Conflict - Конфликт состояния
- 422 Unprocessable Entity - Валидация не прошла
- 429 Too Many Requests - Rate limit
- 500 Internal Server Error - Ошибка сервера
- 503 Service Unavailable - Сервис недоступен

---

## 8. Data Format Specifications

### IRQ-DATA-001: JSON Schema

Все JSON данные валидируются по JSON Schema:

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Agent",
  "type": "object",
  "properties": {
    "id": { "type": "string", "format": "uuid" },
    "name": { "type": "string", "minLength": 1, "maxLength": 255 },
    "type": { "enum": ["analyzer", "transformer", "validator", "reporter", "integration"] }
  },
  "required": ["id", "name", "type"],
  "additionalProperties": false
}
```

---

### IRQ-DATA-002: Datetime Format

Все даты и время используют ISO 8601 формат:
```
2025-10-28T14:30:45.123Z
```

---

### IRQ-DATA-003: UUID Format

Все идентификаторы используют UUID v4:
```
550e8400-e29b-41d4-a716-446655440000
```

---

## 9. Матрица совместимости интерфейсов

| Интерфейс | Версия | Deprecated | Поддержка |
|-----------|--------|-----------|-----------|
| REST API | v1 | No | 2025+ |
| REST API | v2 | No | 2026+ (planned) |
| WebSocket | v1 | No | 2025+ |
| GraphQL | v1 | No | 2026+ (planned) |
| gRPC | v1 | No | 2026+ (planned) |

---

## 10. Критерии приемки интерфейсных требований

Интерфейс считается готовым, когда:

1. ✓ Спецификация документирована в OpenAPI/Swagger
2. ✓ Примеры запросов и ответов работают
3. ✓ Валидация данных протестирована
4. ✓ Error handling покрыт тестами
5. ✓ Performance в пределах нормы

---

**Статус**: 🟢 Утверждено
**Следующий шаг**: Security Requirements (SR-004)
