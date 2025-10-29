# Требования к языку документации и коммуникации

**ВАЖНО**: Вся документация, отчеты, issues, pull requests и комментарии в этом проекте **ДОЛЖНЫ** быть на **РУССКОМ ЯЗЫКЕ**.

## Правила

1. **Документация**: Все файлы `.md` должны быть на русском языке
2. **Issues**: Все описания и комментарии issues должны быть на русском
3. **Pull Requests**: Все описания и комментарии PR должны быть на русском
4. **Сообщения коммитов**: Предпочтительно на русском (допускается английский для технических терминов)
5. **Названия файлов**: Рекомендуется использовать русские названия для документации

## Исключения

- Код (переменные, функции, классы) может использовать английский
- Технические термины и названия технологий остаются на английском
- Конфигурационные файлы и их содержимое могут быть на английском

---

# Стек технологий проекта A2D2

## Backend Framework
- **Ruby on Rails 8.1**: Основной веб-фреймворк
- **Ruby**: Версия указана в `.ruby-version`
- **Puma**: Веб-сервер для обслуживания приложения

## Database
- **SQLite3**: База данных для разработки и тестирования
- **Solid Cache**: Кэширование на основе базы данных
- **Solid Queue**: Очередь задач на основе базы данных
- **Solid Cable**: WebSocket-соединения на основе базы данных

## Frontend Architecture
- **Phlex**: Ruby DSL для создания HTML компонентов (замена ERB/HAML)
- **PhlexyUI**: UI-библиотека компонентов для DaisyUI, построенная на Phlex
- **DaisyUI**: CSS-библиотека компонентов на основе Tailwind CSS
- **Turbo**: SPA-подобное ускорение страниц (Hotwire)
- **Stimulus**: JavaScript фреймворк для интерактивности (Hotwire)
- **Importmap Rails**: Управление JavaScript без сборщика

## Authentication & Authorization
- **Devise**: Аутентификация пользователей
- **Devise Two Factor**: Двухфакторная аутентификация
- **Pundit**: Авторизация и политики доступа
- **JWT**: Токены для API аутентификации
- **bcrypt**: Хеширование паролей

## Security
- **Rack Attack**: Ограничение частоты запросов
- **Secure Headers**: Настройка заголовков безопасности

## AI & LLM Integrations
- **ruby-openai**: Интеграция с OpenAI API
- **anthropic**: Интеграция с Anthropic Claude API
- **httparty**: HTTP клиент для API запросов

## API
- **GraphQL**: GraphQL API (BUS-003)
- **graphql-client**: GraphQL клиент
- **Jbuilder**: Построение JSON API

## Reporting & Data Export
- **Prawn**: Генерация PDF документов
- **Prawn Table**: Таблицы в PDF
- **Caxlsx**: Генерация Excel файлов
- **Caxlsx Rails**: Интеграция Caxlsx с Rails

## Document Processing
- **PDF Reader**: Чтение и обработка PDF (DOC-002, DOC-003)
- **pg_search**: Полнотекстовый поиск (DOC-006)

## Data Processing
- **Builder**: Генерация XML/KML (ROB-005)
- **Dry Validation**: Валидация данных
- **Image Processing**: Обработка изображений

## Scheduling
- **Whenever**: Управление расписанием задач (ANL-005)

## Development Tools
- **Web Console**: Консоль на страницах исключений
- **Debug**: Отладка
- **Bundler Audit**: Аудит зависимостей на уязвимости
- **Brakeman**: Статический анализ безопасности
- **Rubocop Rails Omakase**: Линтер Ruby кода

## Testing
- **Capybara**: Системное тестирование
- **Selenium WebDriver**: Браузерное тестирование
- **SimpleCov**: Покрытие кода тестами
- **Factory Bot Rails**: Фабрики для тестовых данных
- **WebMock**: Мокирование HTTP запросов
- **VCR**: Запись HTTP взаимодействий
- **Shoulda Matchers**: Дополнительные матчеры для тестов
- **Faker**: Генерация фейковых данных

## Deployment
- **Kamal**: Развертывание приложения в Docker контейнерах
- **Thruster**: HTTP кэширование/сжатие для Puma
- **Bootsnap**: Ускорение загрузки через кэширование

## Важные архитектурные особенности

### Компонентная архитектура представлений
- **НЕ используем ERB/HAML шаблоны**
- **Используем Phlex компоненты**: Все представления пишутся как Ruby классы, наследующие от `ApplicationComponent` (который наследует от `Phlex::HTML`)
- **PhlexyUI компоненты**: Доступны через методы-хелперы в `ApplicationComponent` (Button, Card, Badge, Modal и т.д.)
- **Layouts**: Также написаны как Phlex компоненты (например, `Layouts::DashboardLayout`)

### Модульная структура представлений
- Представления организованы в модули по функциональности
- Например: `module DashboardViews; class IndexView` вместо `DashboardIndexView`
- Это позволяет избежать конфликтов имен и логически группировать компоненты
- **ВАЖНО**: Имя модуля представлений НЕ должно совпадать с именем модели (например, используйте `DashboardViews` вместо `Dashboard` если есть модель `Dashboard`)

### Рендеринг в контроллерах
```ruby
# Правильно - рендеринг Phlex компонента с layout
render DashboardViews::IndexView.new, layout: Layouts::DashboardLayout

# НЕправильно - использование ERB шаблонов
render :index
```

### Особенности именования
- **Модели**: Используют стандартные имена классов (например, `class Dashboard < ApplicationRecord`)
- **View компоненты**: Должны быть в модулях для избежания конфликтов (например, `module DashboardViews; class IndexView`)
- **НЕ должно быть конфликтов**: Класс модели и модуль представления не должны иметь одинаковые имена на одном уровне
- Если есть модель `Dashboard`, то модуль представлений должен называться `DashboardViews`, а не `Dashboard`

### Использование маршрутов (URL helpers) в Phlex компонентах

**КРИТИЧЕСКИ ВАЖНО**: В Phlex компонентах НЕТ прямого доступа к Rails хелперам маршрутов!

#### ❌ НЕПРАВИЛЬНО (вызовет ошибку NameError):
```ruby
module Robots
  class IndexView < ApplicationComponent
    def view_template
      a(href: robots_path) { "Список роботов" }
      a(href: robot_path(@robot)) { "Робот" }
      form(action: robots_path, method: "get") do
        # ...
      end
    end
  end
end
```

#### ✅ ПРАВИЛЬНО (используем префикс `helpers.`):
```ruby
module Robots
  class IndexView < ApplicationComponent
    def view_template
      # Для ссылок
      a(href: helpers.robots_path) { "Список роботов" }
      a(href: helpers.robot_path(@robot)) { "Робот" }
      a(href: helpers.new_robot_path) { "Новый робот" }
      a(href: helpers.edit_robot_path(@robot)) { "Редактировать" }

      # Для форм
      form(action: helpers.robots_path, method: "get") do
        # ...
      end

      # С параметрами
      a(href: helpers.tasks_path(robot_id: @robot.id)) { "Задания" }
    end
  end
end
```

#### Основные правила:
1. **ВСЕГДА используйте префикс `helpers.`** перед любым маршрутным хелпером
2. Это касается ВСЕХ хелперов: `_path`, `_url`, и т.д.
3. Примеры хелперов требующих префикс:
   - `robots_path` → `helpers.robots_path`
   - `robot_path(robot)` → `helpers.robot_path(robot)`
   - `new_robot_path` → `helpers.new_robot_path`
   - `edit_robot_path(robot)` → `helpers.edit_robot_path(robot)`
   - `tasks_path` → `helpers.tasks_path`
   - `maintenance_records_path` → `helpers.maintenance_records_path`
   - `login_path`, `logout_path`, `signup_path` → `helpers.login_path`, и т.д.

#### Почему это важно:
- Phlex компоненты наследуют от `Phlex::HTML`, а не от `ActionView::Base`
- Rails хелперы маршрутов доступны только через объект `helpers`
- Без префикса `helpers.` возникает ошибка: `undefined local variable or method 'robots_path' for an instance of Robots::IndexView`

#### Что УЖЕ работает без helpers:
Некоторые хелперы уже включены в `ApplicationComponent` и работают напрямую:
- `time_ago_in_words` (из ActionView::Helpers::DateHelper)
- `form_authenticity_token` (из Phlex::Rails::Helpers)
- Методы мета-тегов и ассетов

---

Issue to solve: undefined
Your prepared branch: issue-147-aecf6cf9
Your prepared working directory: /tmp/gh-issue-solver-1761770187969

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-148-a979595c
Your prepared working directory: /tmp/gh-issue-solver-1761772973895

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-149-68251c54
Your prepared working directory: /tmp/gh-issue-solver-1761774016187

Proceed.