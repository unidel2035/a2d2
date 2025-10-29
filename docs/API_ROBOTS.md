# REST API для управления роботами

## Обзор

Данный документ описывает REST API для управления роботами в системе A2D2.

Базовый URL: `/api/v1/robots`

## Аутентификация

Все запросы к API должны включать токен аутентификации (будет реализовано в следующих версиях):

```
Authorization: Bearer {token}
```

## Endpoints

### 1. Получить список роботов

**GET** `/api/v1/robots`

Возвращает список всех роботов с поддержкой фильтрации и пагинации.

#### Параметры запроса (query parameters)

| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| status | string | Нет | Фильтр по статусу (active, maintenance, repair, retired) |
| manufacturer | string | Нет | Фильтр по производителю |
| page | integer | Нет | Номер страницы (по умолчанию: 1) |
| per_page | integer | Нет | Количество записей на странице (по умолчанию: 25) |

#### Пример запроса

```bash
GET /api/v1/robots?status=active&page=1&per_page=10
```

#### Пример ответа

```json
{
  "robots": [
    {
      "id": 1,
      "serial_number": "ROBOT-0001",
      "model": "AgriBot-X1",
      "manufacturer": "AgriTech Industries",
      "status": "active",
      "location": "Field Section A",
      "total_operation_hours": 1000
    }
  ],
  "page": 1,
  "per_page": 10,
  "total": 1
}
```

---

### 2. Получить информацию о роботе

**GET** `/api/v1/robots/:id`

Возвращает детальную информацию о конкретном роботе.

#### Параметры пути

| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| id | integer | Да | Идентификатор робота |

#### Пример запроса

```bash
GET /api/v1/robots/1
```

#### Пример ответа

```json
{
  "id": 1,
  "serial_number": "ROBOT-0001",
  "model": "AgriBot-X1",
  "manufacturer": "AgriTech Industries",
  "status": "active",
  "location": "Field Section A",
  "total_operation_hours": 1000,
  "manufacture_date": "2023-01-15",
  "last_maintenance_date": "2024-07-15",
  "description": "Agricultural robot for crop monitoring",
  "specifications": null,
  "needs_maintenance": false,
  "maintenance_due_date": "2025-01-15",
  "utilization_rate": 45.5,
  "average_task_duration": 120.5,
  "active_tasks_count": 2,
  "created_at": "2023-01-15T10:00:00Z",
  "updated_at": "2024-10-20T15:30:00Z"
}
```

#### Коды ответов

- `200 OK` - Успешный запрос
- `404 Not Found` - Робот не найден

---

### 3. Создать робота

**POST** `/api/v1/robots`

Создает нового робота в системе.

#### Параметры тела запроса

| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| serial_number | string | Да | Уникальный серийный номер |
| model | string | Нет | Модель робота |
| manufacturer | string | Нет | Производитель |
| manufacture_date | date | Нет | Дата производства |
| location | string | Нет | Местоположение |
| description | string | Нет | Описание робота |
| specifications | text | Нет | Технические характеристики |

#### Пример запроса

```bash
POST /api/v1/robots
Content-Type: application/json

{
  "serial_number": "ROBOT-0002",
  "model": "AgriBot-X2",
  "manufacturer": "AgriTech Industries",
  "manufacture_date": "2024-10-01",
  "location": "Field Section B",
  "description": "Advanced agricultural robot"
}
```

#### Пример ответа

```json
{
  "id": 2,
  "serial_number": "ROBOT-0002",
  "model": "AgriBot-X2",
  "manufacturer": "AgriTech Industries",
  "status": "active",
  "location": "Field Section B",
  "total_operation_hours": 0
}
```

#### Коды ответов

- `201 Created` - Робот успешно создан
- `422 Unprocessable Entity` - Ошибка валидации данных

---

### 4. Обновить робота

**PATCH** `/api/v1/robots/:id`

Обновляет информацию о роботе.

#### Параметры пути

| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| id | integer | Да | Идентификатор робота |

#### Параметры тела запроса

Все поля опциональные. Передавайте только те поля, которые нужно обновить.

| Параметр | Тип | Описание |
|----------|-----|----------|
| model | string | Модель робота |
| manufacturer | string | Производитель |
| status | string | Статус (active, maintenance, repair, retired) |
| location | string | Местоположение |
| description | string | Описание |
| last_maintenance_date | date | Дата последнего обслуживания |
| total_operation_hours | integer | Общее количество часов работы |

#### Пример запроса

```bash
PATCH /api/v1/robots/1
Content-Type: application/json

{
  "status": "maintenance",
  "location": "Service Center",
  "last_maintenance_date": "2024-10-29"
}
```

#### Пример ответа

```json
{
  "id": 1,
  "serial_number": "ROBOT-0001",
  "model": "AgriBot-X1",
  "manufacturer": "AgriTech Industries",
  "status": "maintenance",
  "location": "Service Center",
  "total_operation_hours": 1000
}
```

#### Коды ответов

- `200 OK` - Робот успешно обновлен
- `404 Not Found` - Робот не найден
- `422 Unprocessable Entity` - Ошибка валидации данных

---

### 5. Удалить робота

**DELETE** `/api/v1/robots/:id`

Удаляет робота из системы.

#### Параметры пути

| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| id | integer | Да | Идентификатор робота |

#### Пример запроса

```bash
DELETE /api/v1/robots/1
```

#### Пример ответа

```json
{
  "message": "Robot deleted successfully"
}
```

#### Коды ответов

- `200 OK` - Робот успешно удален
- `404 Not Found` - Робот не найден

---

## Статусы роботов

| Статус | Описание |
|--------|----------|
| active | Робот активен и готов к работе |
| maintenance | Робот на плановом обслуживании |
| repair | Робот в ремонте |
| retired | Робот списан |

---

## Коды ошибок

| Код | Описание |
|-----|----------|
| 200 | Успешный запрос |
| 201 | Ресурс успешно создан |
| 404 | Ресурс не найден |
| 422 | Ошибка валидации данных |
| 500 | Внутренняя ошибка сервера |

---

## Примеры использования

### Пример 1: Получить всех активных роботов

```bash
curl -X GET "http://localhost:3000/api/v1/robots?status=active" \
  -H "Content-Type: application/json"
```

### Пример 2: Создать нового робота

```bash
curl -X POST "http://localhost:3000/api/v1/robots" \
  -H "Content-Type: application/json" \
  -d '{
    "serial_number": "ROBOT-0003",
    "model": "AgriBot-X1",
    "manufacturer": "AgriTech Industries",
    "location": "Field C"
  }'
```

### Пример 3: Отправить робота на обслуживание

```bash
curl -X PATCH "http://localhost:3000/api/v1/robots/1" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "maintenance",
    "last_maintenance_date": "2024-10-29"
  }'
```

### Пример 4: Получить детальную информацию о роботе

```bash
curl -X GET "http://localhost:3000/api/v1/robots/1" \
  -H "Content-Type: application/json"
```

---

## Связанные ресурсы

- [SPECIFICATION.md](../SPECIFICATION.md) - Основная спецификация системы
- [Модель Robot](../app/models/robot.rb) - Исходный код модели
- [API контроллер](../app/controllers/api/v1/robots_controller.rb) - Реализация API

---

## История изменений

| Дата | Версия | Описание |
|------|--------|----------|
| 2024-10-29 | 1.0.0 | Первая версия API для управления роботами |
