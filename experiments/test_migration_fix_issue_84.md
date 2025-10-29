# Тестирование исправления миграций для Issue #84

## Описание проблемы

При выполнении миграций возникала ошибка:
```
SQLite3::SQLException: table "llm_requests" already exists
```

### Корневая причина

Параметр `if_not_exists: true` в ActiveRecord **не работает корректно с SQLite3** при использовании `create_table`. Это известная проблема Rails с адаптером SQLite3.

Когда Rails генерирует SQL для создания таблицы с внешними ключами и ограничениями, SQLite3 не корректно обрабатывает флаг `IF NOT EXISTS` в составе сложного SQL-запроса.

## Решение

Вместо использования `if_not_exists: true` (которое не работает), используем явную проверку существования таблицы через метод `table_exists?`:

### Было (не работает):
```ruby
class CreateLlmRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_requests, if_not_exists: true do |t|
      # ...
    end
  end
end
```

### Стало (работает):
```ruby
class CreateLlmRequests < ActiveRecord::Migration[8.1]
  def change
    unless table_exists?(:llm_requests)
      create_table :llm_requests do |t|
        # ...
      end
    end
  end
end
```

## Изменённые файлы

1. **db/migrate/20251028190006_create_llm_requests.rb**
   - Заменили `if_not_exists: true` на `unless table_exists?(:llm_requests)`
   - Удалили `if_not_exists: true` из всех `add_index`

2. **db/migrate/20251028190007_create_llm_usage_summaries.rb**
   - Заменили `if_not_exists: true` на `unless table_exists?(:llm_usage_summaries)`
   - Удалили `if_not_exists: true` из всех `add_index`

## Тестовые сценарии

### Сценарий 1: Создание новой БД через db:setup
```bash
# Удаляем существующую БД
rm -f db/development.sqlite3 db/test.sqlite3

# Создаём новую БД через db:setup
# (загружает schema.rb и выполняет pending миграции)
RAILS_ENV=development bundle exec rails db:setup

# Ожидаемый результат: успешное создание БД без ошибок
```

### Сценарий 2: Миграция на существующей БД
```bash
# Загружаем schema.rb (создаёт все таблицы из schema.rb)
RAILS_ENV=development bundle exec rails db:schema:load

# Выполняем миграции (должны пропустить существующие таблицы)
RAILS_ENV=development bundle exec rails db:migrate

# Ожидаемый результат: миграции выполняются без ошибок,
# таблицы llm_requests и llm_usage_summaries не дублируются
```

### Сценарий 3: Откат и повторное применение миграций
```bash
# Откатываем последние 2 миграции
RAILS_ENV=development bundle exec rails db:rollback STEP=2

# Проверяем статус миграций
RAILS_ENV=development bundle exec rails db:migrate:status

# Повторно применяем миграции
RAILS_ENV=development bundle exec rails db:migrate

# Ожидаемый результат: успешный откат и повторное применение
```

### Сценарий 4: Проверка в тестовой среде
```bash
# Создаём тестовую БД
RAILS_ENV=test bundle exec rails db:setup

# Ожидаемый результат: успешное создание тестовой БД
```

## Почему это правильное решение?

1. **Совместимость с SQLite3**: Метод `table_exists?` работает во всех адаптерах БД
2. **Надёжность**: Явная проверка гарантирует корректное поведение
3. **Откат миграций**: Позволяет корректно откатывать миграции при необходимости
4. **Идиоматичность Rails**: Это рекомендуемый подход в Rails для условного создания таблиц

## Связь с предыдущими попытками решения

- **PR #81**: Восстановил таблицы в schema.rb
- **PR #83**: Попытался использовать `if_not_exists: true` (не сработало из-за ограничений SQLite3)
- **Текущее решение (PR #85)**: Использует `table_exists?` - работает корректно со всеми адаптерами БД

## Техническая документация

### Почему if_not_exists не работает в SQLite3?

SQLite3 поддерживает синтаксис `CREATE TABLE IF NOT EXISTS`, но ActiveRecord генерирует сложные SQL-запросы с foreign keys и constraints в одном statement. При этом:

1. ActiveRecord пытается добавить `IF NOT EXISTS` в основной `CREATE TABLE`
2. Но также добавляет `FOREIGN KEY` constraints в том же запросе
3. SQLite3 не может корректно обработать комбинацию `IF NOT EXISTS` с inline constraints

Результат: запрос падает с ошибкой "table already exists".

### Решение через table_exists?

Метод `table_exists?` выполняет отдельный SQL-запрос для проверки существования таблицы:
```sql
SELECT name FROM sqlite_master WHERE type='table' AND name='llm_requests'
```

Если таблица существует, миграция пропускает создание. Это работает надёжно во всех адаптерах БД.
