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

---

Issue to solve: undefined
Your prepared branch: issue-10-e5e48284
Your prepared working directory: /tmp/gh-issue-solver-1761668034661
Your forked repository: konard/a2d2
Original repository (upstream): unidel2035/a2d2

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-38-1a27e0ad
Your prepared working directory: /tmp/gh-issue-solver-1761679193972

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-43-8e946708
Your prepared working directory: /tmp/gh-issue-solver-1761680870340

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-60-12430ac2
Your prepared working directory: /tmp/gh-issue-solver-1761685599399

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-66-fcca4299
Your prepared working directory: /tmp/gh-issue-solver-1761716951433

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-72-30c89862
Your prepared working directory: /tmp/gh-issue-solver-1761718660008

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-105-f7e3c336
Your prepared working directory: /tmp/gh-issue-solver-1761742370057

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-126-448bc928
Your prepared working directory: /tmp/gh-issue-solver-1761751045120

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-132-c65abfe3
Your prepared working directory: /tmp/gh-issue-solver-1761752940447

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-136-10be0a93
Your prepared working directory: /tmp/gh-issue-solver-1761753980764

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-138-3cec7550
Your prepared working directory: /tmp/gh-issue-solver-1761754857687

Proceed.

---

Issue to solve: undefined
Your prepared branch: issue-143-fd98d72a
Your prepared working directory: /tmp/gh-issue-solver-1761765341568

Proceed.