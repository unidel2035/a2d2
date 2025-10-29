# Руководство по тестированию A2D2

Этот документ описывает структуру тестов и способы их запуска для проекта A2D2.

## Структура тестов

Тесты организованы по типам согласно Rails convention:

### 1. Unit тесты (Модели)

Расположение: `test/models/`

Тесты для бизнес-логики моделей:
- **robot_test.rb** - Тесты модели Robot (валидации, associations, методы)
- **document_test.rb** - Тесты модели Document с поиском (Searchable concern)
- **maintenance_record_test.rb** - Тесты модели MaintenanceRecord (lifecycle, callbacks)
- **user_test.rb** - Тесты модели User (Devise authentication)
- **agent_test.rb** - Тесты модели Agent

**Пример запуска:**
```bash
rails test test/models/robot_test.rb
rails test test/models/document_test.rb
```

### 2. Integration тесты (Контроллеры)

Расположение: `test/controllers/`

Тесты для HTTP endpoints и контроллерной логики:
- **robots_controller_test.rb** - CRUD операции для роботов
- **dashboard_controller_test.rb** - Dashboard с Phlex компонентами
- **agents_controller_test.rb** - Управление AI-агентами
- **maintenance_records_controller_test.rb** - Управление обслуживанием
- **tasks_controller_test.rb** - Управление задачами

**Пример запуска:**
```bash
rails test test/controllers/
rails test test/controllers/robots_controller_test.rb
```

### 3. System тесты (End-to-End)

Расположение: `test/system/`

Полноценные E2E тесты с браузером (Selenium + Capybara):
- **dashboard_test.rb** - Навигация по dashboard
- **robots_test.rb** - Полный цикл работы с роботами (CRUD)
- **authentication_test.rb** - Тесты аутентификации (login, logout, registration)

**Примечание:** System тесты помечены как `skip` из-за необходимости настройки Devise authentication в тестовом окружении.

**Пример запуска:**
```bash
rails test:system
rails test test/system/robots_test.rb
```

### 4. Component тесты (Phlex)

Расположение: `test/components/`

Тесты для Phlex компонентов (view components):
- **dashboard_index_view_test.rb** - Dashboard view component
- **robots_index_view_test.rb** - Robots list view component
- **agents_index_view_test.rb** - Agents list view component

**Пример запуска:**
```bash
rails test test/components/
```

## Fixtures

Расположение: `test/fixtures/`

Тестовые данные для всех тестов:
- **robots.yml** - Тестовые роботы (3 записи: active, maintenance, retired)
- **users.yml** - Тестовые пользователи (admin, operator, technician)
- **documents.yml** - Тестовые документы
- **maintenance_records.yml** - Записи обслуживания
- **agents.yml** - AI-агенты

## Запуск тестов

### Запустить все тесты
```bash
rails test
```

### Запустить тесты по типам
```bash
# Только unit тесты (модели)
rails test:models

# Только integration тесты (контроллеры)
rails test:controllers

# Только system тесты
rails test:system
```

### Запустить конкретный файл
```bash
rails test test/models/robot_test.rb
rails test test/controllers/robots_controller_test.rb
```

### Запустить конкретный тест
```bash
rails test test/models/robot_test.rb:16  # Запустить тест на строке 16
```

### С покрытием кода (SimpleCov)
```bash
COVERAGE=true rails test
```

После выполнения откройте `coverage/index.html` в браузере для просмотра отчета.

### Параллельное выполнение
```bash
rails test
```

Тесты автоматически выполняются параллельно (см. `test_helper.rb`).

## Отладка тестов

### Использование debug
```ruby
test "my test" do
  debugger  # Точка останова
  assert something
end
```

### Просмотр SQL запросов
```bash
VERBOSE=1 rails test
```

### Отключение параллелизма
В `test/test_helper.rb` закомментируйте:
```ruby
# parallelize(workers: :number_of_processors)
```

## Покрытие кода

Проект использует SimpleCov для отслеживания покрытия кода.

**Минимальные требования:**
- Общее покрытие: >= 80%
- Покрытие отдельного файла: >= 70%

**Настройка:** `test/test_helper.rb`

**Просмотр отчета:**
```bash
COVERAGE=true rails test
open coverage/index.html  # macOS
xdg-open coverage/index.html  # Linux
```

## CI/CD

Тесты автоматически запускаются в GitHub Actions при:
- Pull Request
- Push в main branch

**Конфигурация:** `.github/workflows/ci.yml`

**Jobs:**
- `scan_ruby` - Brakeman security scan
- `scan_js` - Importmap audit
- `lint` - RuboCop style checking
- `test` - Все unit и integration тесты
- `system-test` - System тесты с браузером

## Лучшие практики

### 1. Используйте fixtures
```ruby
def setup
  @robot = robots(:one)  # Из fixtures
end
```

### 2. Тестируйте edge cases
```ruby
test "should handle nil values" do
  @robot.manufacturer = nil
  assert_not @robot.valid?
end
```

### 3. Используйте describe блоки
```ruby
test "should search documents by title" do
  # ...
end

test "should search documents by content" do
  # ...
end
```

### 4. Избегайте зависимостей между тестами
Каждый тест должен быть независимым и выполняться в любом порядке.

### 5. Очищайте данные в teardown
```ruby
def teardown
  # Cleanup if needed
end
```

## Устранение проблем

### Ошибка: База данных не найдена
```bash
rails db:test:prepare
```

### Ошибка: Fixtures не загружаются
Проверьте `test_helper.rb`:
```ruby
fixtures :all
```

### Ошибка: Chrome/Selenium не найден (system tests)
```bash
# Ubuntu/Debian
sudo apt-get install chromium-browser chromium-chromedriver

# macOS
brew install --cask google-chrome
brew install chromedriver
```

### Ошибка: Тесты падают случайным образом
Отключите параллелизм и проверьте на race conditions.

## Дополнительные инструменты

### FactoryBot (если установлен)
```ruby
# Вместо fixtures можно использовать фабрики
robot = create(:robot, manufacturer: "TestCorp")
```

### WebMock (для HTTP тестов)
```ruby
stub_request(:get, "http://api.example.com")
  .to_return(status: 200, body: "OK")
```

### VCR (для записи HTTP взаимодействий)
```ruby
VCR.use_cassette("external_api") do
  # HTTP requests will be recorded
end
```

## Ссылки

- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)
- [Minitest Documentation](https://github.com/minitest/minitest)
- [Capybara Documentation](https://github.com/teamcapybara/capybara)
- [SimpleCov](https://github.com/simplecov-ruby/simplecov)
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers)

---

_Создано: 2025-10-29_
_Issue: #150 - Этап 4: Тестирование_
