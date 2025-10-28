# Цифровая Платформа "Код Урожая" - Документация

## Обзор

Цифровая платформа "Код Урожая" (Harvest Code) - это мультиагентная экосистема для управления агропромышленным комплексом, реализованная как отдельный интерфейс в рамках платформы A2D2.

## Концепция

Платформа основана на концепции из документа "К вопросу о концепции архитектуры цифровой экосистемы" и реализует:

### Трехуровневую архитектуру:

1. **Уровень IoT / БИПО (Безопасный Интернет Подвижных Объектов)**
   - Телематика и навигация
   - Управление беспилотной техникой
   - Сбор данных с IoT устройств
   - M2M коммуникации

2. **Микро/Мезо-экономический уровень**
   - Федеративная мультиагентная платформа
   - Управление фермерскими хозяйствами
   - Логистика и транспортировка
   - Переработка продукции
   - Смарт-контракты

3. **Макро-экономический уровень**
   - Межотраслевая кооперация
   - Интеграция с машиностроением, химической промышленностью
   - Связь с энергетикой, ритейлом, HoReCa

### Ключевые принципы:

- **Мультиагентность**: Различные экономические агенты взаимодействуют в экосистеме
- **Суверенитет данных**: Каждый агент контролирует свои данные
- **Федеративная модель**: Децентрализованное управление
- **Edge Computing**: Автономная работа узлов ("сначала офлайн")
- **Оркестрация**: Мета-слой координирует работу агентов

## Архитектура Реализации

### Модели Данных

#### 1. AgroAgent (Агент экосистемы)
Представляет экономический агент в системе:

```ruby
class AgroAgent < ApplicationRecord
  # Типы агентов
  AGENT_TYPES = %w[
    farmer          # Фермер
    logistics       # Логистика
    processor       # Переработчик
    retailer        # Ритейлер
    regulator       # Регулятор
    equipment_operator  # Оператор техники
    warehouse       # Склад
    marketplace     # Маркетплейс
    analytics       # Аналитика
  ]

  # Уровни архитектуры
  LEVELS = %w[
    iot_layer       # IoT уровень
    micro_meso      # Микро/Мезо уровень
    macro           # Макро уровень
  ]
end
```

**Основные атрибуты:**
- `name`: Имя агента
- `agent_type`: Тип агента (farmer, logistics, processor, и т.д.)
- `level`: Уровень архитектуры (iot_layer, micro_meso, macro)
- `status`: Статус агента (active, inactive, offline)
- `capabilities`: JSON массив возможностей агента
- `configuration`: JSON конфигурация
- `last_heartbeat`: Последний heartbeat для мониторинга доступности
- `success_rate`: Процент успешных задач

#### 2. AgroTask (Задачи агентов)
Задачи, выполняемые агентами:

```ruby
TASK_TYPES = %w[
  data_collection  # Сбор данных
  analysis         # Анализ
  optimization     # Оптимизация
  coordination     # Координация
  monitoring       # Мониторинг
  prediction       # Прогнозирование
  validation       # Валидация
  execution        # Выполнение
  reporting        # Отчетность
]
```

#### 3. Farm (Фермерское хозяйство)
Представляет сельскохозяйственное предприятие:
- Связано с агентом типа `farmer`
- Содержит посевы (Crops) и технику (Equipment)
- Отслеживает площадь, местоположение, координаты

#### 4. Crop (Посевы)
Отслеживание выращивания культур:
- Тип культуры (пшеница, кукуруза, и т.д.)
- Площадь посадки
- Ожидаемая и фактическая урожайность
- Даты посадки и сбора урожая
- Статус (planning, planted, growing, harvesting, harvested)

#### 5. Equipment (Техника)
Сельскохозяйственная техника и IoT устройства:
- Типы: трактор, комбайн, дрон, сенсор, и т.д.
- Статус доступности
- Флаг автономности (для беспилотной техники)
- Телеметрические данные

#### 6. LogisticsOrder (Логистические заказы)
Транспортировка и доставка:
- Типы: transport, storage, delivery, collection
- Пункты отправления и назначения
- Количество и тип продукции
- Данные маршрута

#### 7. ProcessingBatch (Партии переработки)
Отслеживание переработки продукции:
- Входная и выходная продукция
- Количества
- Коэффициент конверсии
- Метрики качества

#### 8. MarketOffer (Рыночные предложения)
Спрос и предложение на маркетплейсе:
- Типы: supply (предложение), demand (спрос)
- Тип продукта
- Количество и цена
- Статус (active, matched, completed, cancelled)

#### 9. SmartContract (Смарт-контракты)
Автоматизированные соглашения между агентами:
- Покупатель и продавец (оба - AgroAgent)
- Типы контрактов
- Условия (terms) в JSON
- Статусы выполнения

#### 10. AgentCoordination (Координация агентов)
Мультиагентная оркестрация:
- Типы: workflow, negotiation, optimization, collaboration
- Список участвующих агентов
- Данные координации

### Сервисы

#### 1. AgroAgents::BaseAgroAgent
Базовый класс для всех агентов:
- Интеграция с LLM для интеллектуальных решений
- Управление heartbeat
- Логирование выполнения

#### 2. AgroAgents::FarmerAgent
Агент фермерского хозяйства:
- Сбор данных о ферме
- Анализ производительности посевов
- Оптимизация графика посадки
- Мониторинг посевов
- Прогнозирование урожая

#### 3. AgroAgents::LogisticsAgent
Агент логистики:
- Координация доставок
- Оптимизация маршрутов (с использованием LLM)
- Мониторинг отправлений
- Анализ эффективности логистики

#### 4. AgroAgents::ProcessorAgent
Агент переработки:
- Управление партиями переработки
- Мониторинг производства
- Валидация качества (с использованием LLM)
- Анализ производства

#### 5. AgroAgents::MarketplaceAgent
Агент маркетплейса:
- Сведение предложений спроса и предложения
- Анализ рынка
- Мониторинг предложений
- Прогнозирование цен (с использованием LLM)

#### 6. AgroOrchestrator
Мета-слой оркестрации:
- Назначение задач подходящим агентам
- Балансировка нагрузки
- Координация сложных workflow
- Мониторинг всей экосистемы
- Health check агентов
- Перебалансировка задач

### Jobs (Фоновые задачи)

#### AgroTaskExecutionJob
Асинхронное выполнение задач агентов:
- Определяет тип агента
- Создает соответствующий сервис
- Выполняет задачу
- Обрабатывает ошибки

### Контроллеры

#### 1. AgroPlatformController
Главный контроллер платформы:
- `index`: Главная панель управления
- `ecosystem`: Обзор экосистемы агентов
- `monitoring`: Мониторинг системы

#### 2. AgroAgentsController
Управление агентами:
- CRUD операции
- Heartbeat endpoint
- Просмотр задач и связанных сущностей

#### 3. AgroTasksController
Управление задачами:
- Просмотр задач
- Создание новых задач (через оркестратор)
- Повторное выполнение failed задач

#### 4. FarmsController
Управление фермами:
- CRUD операции
- Просмотр посевов и техники

#### 5. MarketOffersController
Управление маркетплейсом:
- CRUD предложений
- Действие match для автоматического сведения

### Маршруты

```ruby
# Главная страница платформы
GET /agro

# Обзор экосистемы
GET /agro/ecosystem

# Мониторинг
GET /agro/monitoring

# Агенты
resources :agro_agents
POST /agro_agents/:id/heartbeat

# Задачи
resources :agro_tasks
POST /agro_tasks/:id/retry

# Фермы
resources :farms

# Рыночные предложения
resources :market_offers
POST /market_offers/match

# Смарт-контракты (только просмотр)
resources :smart_contracts

# Координации агентов
resources :agent_coordinations
```

## Установка и Использование

### 1. Запуск миграций

```bash
bin/rails db:migrate
```

Это создаст все необходимые таблицы:
- agro_agents
- agro_tasks
- farms
- crops
- equipment
- logistics_orders
- processing_batches
- market_offers
- smart_contracts
- agent_coordinations

### 2. Создание тестовых данных

```ruby
# Создание агента-фермера
farmer_agent = AgroAgent.create!(
  name: "Агро-Хозяйство 'Урожай'",
  agent_type: 'farmer',
  level: 'micro_meso',
  status: 'active',
  capabilities: ['data_collection', 'analysis', 'monitoring', 'prediction']
)

# Создание фермы
farm = Farm.create!(
  name: "Ферма 'Золотое поле'",
  farm_type: 'crop',
  area: 1000.0,
  location: "Краснодарский край",
  agro_agent: farmer_agent
)

# Создание посева
crop = Crop.create!(
  farm: farm,
  crop_type: 'wheat',
  area_planted: 500.0,
  expected_yield: 2500.0,
  planting_date: Date.current - 60.days,
  harvest_date: Date.current + 30.days,
  status: 'growing'
)

# Создание агента логистики
logistics_agent = AgroAgent.create!(
  name: "Транспортная компания 'Быстрая доставка'",
  agent_type: 'logistics',
  level: 'micro_meso',
  status: 'active',
  capabilities: ['coordination', 'optimization', 'monitoring']
)

# Создание агента маркетплейса
marketplace_agent = AgroAgent.create!(
  name: "Агро-Маркетплейс",
  agent_type: 'marketplace',
  level: 'micro_meso',
  status: 'active',
  capabilities: ['coordination', 'analysis', 'prediction']
)

# Создание предложения на продажу
supply_offer = MarketOffer.create!(
  agro_agent: farmer_agent,
  offer_type: 'supply',
  product_type: 'wheat',
  quantity: 2000.0,
  unit: 'tons',
  price_per_unit: 15000.0,
  status: 'active',
  valid_until: Date.current + 30.days
)
```

### 3. Работа с оркестратором

```ruby
# Инициализация оркестратора
orchestrator = AgroOrchestrator.new

# Назначение задачи
result = orchestrator.assign_task(
  'analysis',
  { farm_id: farm.id },
  priority: 'high'
)
# => { success: true, task_id: 1, agent_id: 1 }

# Мониторинг экосистемы
status = orchestrator.monitor_ecosystem
# => {
#   total_agents: 3,
#   active_agents: 3,
#   online_agents: 3,
#   offline_agents: [],
#   pending_tasks: 5,
#   active_coordinations: 0
# }

# Health check
health = orchestrator.health_check
# => [
#   {
#     agent_id: 1,
#     name: "Агро-Хозяйство 'Урожай'",
#     status: 'active',
#     online: true,
#     success_rate: 100.0,
#     pending_tasks: 2,
#     last_heartbeat: ...
#   },
#   ...
# ]

# Координация workflow
result = orchestrator.coordinate_workflow(
  'workflow',
  [farmer_agent.id, logistics_agent.id],
  {
    steps: [
      { task_type: 'data_collection', input: { farm_id: farm.id } },
      { task_type: 'coordination', input: { delivery: true } }
    ]
  }
)
```

### 4. Доступ к интерфейсу

После запуска Rails приложения:

1. Откройте браузер и перейдите по адресу: `http://localhost:3000/agro`
2. Вы увидите главную панель управления с:
   - Статусом экосистемы
   - Обзором трехуровневой архитектуры
   - Быстрыми действиями
   - Последними контрактами и задачами

3. Навигация:
   - `/agro` - Главная страница
   - `/agro/ecosystem` - Обзор экосистемы агентов
   - `/agro/monitoring` - Мониторинг задач и координаций
   - `/agro_agents` - Управление агентами
   - `/farms` - Управление фермами
   - `/market_offers` - Маркетплейс
   - `/agro_tasks` - Просмотр задач

## Интеграция с LLM

Агенты используют LLM (через LLM::Client) для интеллектуальных решений:

1. **Оптимизация графика посадки** (FarmerAgent)
2. **Оптимизация логистических маршрутов** (LogisticsAgent)
3. **Оценка качества продукции** (ProcessorAgent)
4. **Прогнозирование цен** (MarketplaceAgent)

Все агенты имеют fallback на rule-based логику, если LLM недоступен.

## Расширение Платформы

### Добавление нового типа агента

1. Добавьте тип в `AgroAgent::AGENT_TYPES`
2. Создайте сервис в `app/services/agro_agents/your_agent.rb`
3. Наследуйтесь от `BaseAgroAgent`
4. Реализуйте метод `execute_task`
5. Добавьте обработку в `AgroTaskExecutionJob`

### Добавление нового типа задачи

1. Добавьте тип в `AgroTask::TASK_TYPES`
2. Реализуйте обработку в соответствующем агенте
3. Обновите capabilities агентов

### Добавление нового типа координации

1. Добавьте тип в `AgentCoordination::COORDINATION_TYPES`
2. Реализуйте логику в `AgroOrchestrator`

## Соответствие Концепции

Реализация полностью соответствует концепции из документа:

✅ **Трехуровневая архитектура** (IoT, Микро/Мезо, Макро)
✅ **Мультиагентная система** (9 типов агентов)
✅ **Федеративная модель** (каждый агент автономен)
✅ **Оркестрация** (AgroOrchestrator как мета-слой)
✅ **Смарт-контракты** (автоматические соглашения)
✅ **Маркетплейс** (сведение спроса и предложения)
✅ **IoT интеграция** (Equipment с телеметрией)
✅ **Визуальный интерфейс** (панель управления)

## Дальнейшее Развитие

### Краткосрочные цели:
- [ ] Добавить визуализацию координат на картах
- [ ] Расширить IoT интеграцию (реальные устройства)
- [ ] Добавить WebSocket для real-time обновлений
- [ ] Создать мобильное приложение для фермеров

### Среднесрочные цели:
- [ ] Интеграция с внешними метеосервисами
- [ ] Предиктивная аналитика урожайности
- [ ] Blockchain для immutable контрактов
- [ ] Federated learning между агентами

### Долгосрочные цели:
- [ ] Полная автономия беспилотной техники
- [ ] Интеграция с государственными системами
- [ ] Межрегиональная и межстрановая кооперация
- [ ] AI-powered ценообразование

## Поддержка

Для вопросов и предложений создавайте issues в GitHub репозитории A2D2.

---

**Версия:** 1.0.0
**Дата:** 2025-10-28
**Автор:** A2D2 Development Team
