# Тест исправления миграций

## Проблема
После коммита c8217c3 таблицы `llm_requests` и `llm_usage_summaries` были добавлены в schema.rb, но миграции пытаются создать их заново, что приводит к ошибке:
```
SQLite3::SQLException: table "llm_requests" already exists
```

## Решение
Добавлены параметры `if_not_exists: true` для:
- Создания таблиц
- Создания индексов

## Изменённые файлы
1. `db/migrate/20251028190006_create_llm_requests.rb`
   - Добавлено `if_not_exists: true` к `create_table`
   - Добавлено `if_not_exists: true` ко всем `add_index`

2. `db/migrate/20251028190007_create_llm_usage_summaries.rb`
   - Добавлено `if_not_exists: true` к `create_table`
   - Добавлено `if_not_exists: true` ко всем `add_index`

## Проверка
Миграции теперь безопасны для выполнения в любом сценарии:
- При создании новой БД (через `rails db:setup`)
- При существующей БД с таблицами (через `rails db:migrate`)
- При откате и повторном применении миграций

## Тестирование

### Сценарий 1: Новая БД
```bash
rm -f db/development.sqlite3
rails db:setup
# Ожидаемо: успешное создание БД
```

### Сценарий 2: Существующая БД с таблицами
```bash
rails db:schema:load  # загружает schema.rb, создаёт таблицы
rails db:migrate      # применяет миграции
# Ожидаемо: миграции пропускают создание существующих таблиц
```

### Сценарий 3: Откат и повтор
```bash
rails db:rollback STEP=2
rails db:migrate
# Ожидаемо: успешный откат и повторное применение
```
