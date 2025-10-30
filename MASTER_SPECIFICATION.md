# Главная спецификация проекта A2D2 (Automation to Automation Delivery)

**Версия документа**: 2.0
**Дата**: 30 октября 2025
**Статус**: ✅ Утверждено
**Методология**: MBSE (Model-Based Systems Engineering)

---

## 📋 Содержание

1. [Введение](#1-введение)
2. [Концепция проекта](#2-концепция-проекта)
3. [Архитектура системы](#3-архитектура-системы)
4. [Требования к системе](#4-требования-к-системе)
5. [Технологический стек](#5-технологический-стек)
6. [Модель данных](#6-модель-данных)
7. [Этапы разработки](#7-этапы-разработки)
8. [Процесс развертывания](#8-процесс-развертывания)
9. [Требования к инфраструктуре](#9-требования-к-инфраструктуре)
10. [Поток создания issues](#10-поток-создания-issues)
11. [Критерии приемки](#11-критерии-приемки)
12. [Приложения](#12-приложения)

---

## 1. Введение

### 1.1 Цель документа

Данный документ представляет собой **главную спецификацию проекта A2D2**, предназначенную для полного разворачивания системы в новом репозитории. Спецификация содержит:

- Полное описание архитектуры системы
- Детальные требования по стандартам MBSE
- Поэтапный план разработки с иерархией задач
- Инструкции по развертыванию и конфигурации
- Шаблоны для автоматического создания issues

### 1.2 Область применения

**A2D2** — это платформа «Автоматизации автоматизации» на базе Ruby on Rails 8.1, где:

- ИИ-агенты управляют бизнес-процессами автономно
- Мета-система координирует работу агентов
- Система самоорганизуется без участия человека
- Обеспечивается технологический суверенитет РФ

### 1.3 Целевая аудитория документа

- **Архитекторы** — для понимания системной архитектуры
- **Разработчики** — для реализации компонентов системы
- **DevOps-инженеры** — для развертывания инфраструктуры
- **Менеджеры проектов** — для планирования и контроля этапов
- **ИИ-агенты Claude** — для автоматического создания issues и кода

### 1.4 Стандарты и методология

Спецификация разработана в соответствии с:

- **ISO/IEC/IEEE 15288** — Процессы жизненного цикла систем
- **ISO/IEC 25010** — Качество программного обеспечения
- **ГОСТ Р 57193-2016** — Системная инженерия
- **ГОСТ Р ИСО/МЭК 12207** — Процессы жизненного цикла ПО
- **RFC 2119** — Ключевые слова для обозначения уровней требований
- **MBSE** — Model-Based Systems Engineering

---

## 2. Концепция проекта

### 2.1 Видение проекта

**A2D2** — это первая российская платформа с архитектурой **"ИИ управляет ИИ"**, где:

1. **Интеллектуальные агенты** выполняют специализированные задачи:
   - Анализ данных (Analyzer Agent)
   - Трансформация данных (Transformer Agent)
   - Валидация (Validator Agent)
   - Генерация отчетов (Reporter Agent)
   - Интеграция систем (Integration Agent)

2. **Мета-слой** обеспечивает координацию:
   - Orchestrator — центральный координатор
   - Task Queue Manager — управление очередью задач
   - Agent Registry — реестр агентов с мониторингом
   - Verification Layer — проверка качества работы
   - Memory Management — управление контекстной памятью

3. **Самоорганизующаяся экосистема**:
   - Автоматическое распределение задач
   - Верификация результатов
   - Обучение на ошибках
   - Адаптация к изменениям

### 2.2 Ключевые преимущества

| Преимущество | Описание |
|--------------|----------|
| 🤖 **Автоматизация автоматизации** | ИИ управляет ИИ — уникальная архитектура с мета-слоем |
| 🔌 **Единый API для LLM** | Доступ к GPT, Claude, DeepSeek, Gemini через один интерфейс |
| 🧠 **Интеллектуальные агенты** | Специализированные агенты с контекстной памятью |
| 🔄 **Самоорганизация** | Мета-слой мониторит, верифицирует и адаптирует систему |
| 📦 **Готовые решения** | Модули для документов, процессов, аналитики, интеграций |
| 🛡️ **Технологический суверенитет** | Российская разработка, независимая от санкций |

### 2.3 Бизнес-цели

1. **BG-001**: Создать платформу для автономной автоматизации бизнес-процессов
2. **BG-002**: Обеспечить масштабируемость до 100+ агентов и 10000+ задач одновременно
3. **BG-003**: Достичь 99.5% uptime и P99 response time < 1 секунда
4. **BG-004**: Предоставить единый API для всех популярных LLM провайдеров
5. **BG-005**: Обеспечить полное соответствие российскому законодательству

---

## 3. Архитектура системы

### 3.1 Системный контекст

```
┌────────────────────────────────────────────────────────────────┐
│                      External Systems                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │   LLM    │  │   1C     │  │   ERP    │  │   CRM    │      │
│  │Providers │  │  System  │  │  System  │  │  System  │      │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘      │
└────────┼─────────────┼─────────────┼─────────────┼────────────┘
         │             │             │             │
         └─────────────┼─────────────┼─────────────┘
                       │             │
         ┌─────────────▼─────────────▼─────────────┐
         │        A2D2 Platform Core               │
         │  ┌───────────────────────────────────┐  │
         │  │       Meta-Layer                  │  │
         │  │  (Orchestration & Coordination)   │  │
         │  └───────────────┬───────────────────┘  │
         │                  │                       │
         │  ┌───────────────▼───────────────────┐  │
         │  │      Agent Ecosystem              │  │
         │  │  (Specialized AI Agents)          │  │
         │  └───────────────┬───────────────────┘  │
         │                  │                       │
         │  ┌───────────────▼───────────────────┐  │
         │  │      Business Modules             │  │
         │  │  (Documents, Processes, Reports)  │  │
         │  └───────────────────────────────────┘  │
         └───────────────────────────────────────────┘
                       │
         ┌─────────────▼─────────────┐
         │         Users             │
         │  (Web UI, Mobile, API)    │
         └───────────────────────────┘
```

### 3.2 Архитектура мета-слоя

```
┌─────────────────────────────────────────────────────────────┐
│                       Meta-Layer                             │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Orchestrator (Core)                     │  │
│  │  - Task Distribution (Round-robin, Least-loaded)     │  │
│  │  - Agent Lifecycle Management                        │  │
│  │  - Strategy Selection (Capability-match)             │  │
│  └───────┬────────────────────────────────────┬─────────┘  │
│          │                                    │             │
│  ┌───────▼────────┐                  ┌────────▼─────────┐  │
│  │ Task Queue     │                  │  Agent Registry  │  │
│  │   Manager      │                  │                  │  │
│  │ - Prioritization│◄────────────────►│ - Heartbeat     │  │
│  │ - Retry Logic  │                  │ - Capabilities  │  │
│  │ - Deadlines    │                  │ - Status        │  │
│  └───────┬────────┘                  └────────┬─────────┘  │
│          │                                    │             │
│  ┌───────▼────────────────────────────────────▼─────────┐  │
│  │              Verification Layer                      │  │
│  │  - Quality Checks                                    │  │
│  │  - Result Validation                                 │  │
│  │  - Error Handling & Task Reassignment                │  │
│  └───────┬──────────────────────────────────────────────┘  │
│          │                                                  │
│  ┌───────▼──────────────────────────────────────────────┐  │
│  │              Memory Management                       │  │
│  │  - Context Storage (Solid Cache)                     │  │
│  │  - Intermediate Results Caching                      │  │
│  │  - Long-term Knowledge Base                          │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 3.3 Архитектура агентной системы

```
┌─────────────────────────────────────────────────────────────┐
│                    Agent Ecosystem                           │
│                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │ Analyzer Agent │  │Transformer Agent│ │Validator Agent│  │
│  │                │  │                │  │               │  │
│  │ - Data Analysis│  │ - Data Transform│ │ - Validation  │  │
│  │ - Statistics   │  │ - Cleansing    │  │ - Rules Check │  │
│  │ - Anomalies    │  │ - Conversion   │  │ - Quality     │  │
│  └────────┬───────┘  └────────┬───────┘  └──────┬────────┘  │
│           │                   │                  │           │
│           └───────────────────┼──────────────────┘           │
│                               │                              │
│  ┌────────────────┐  ┌────────▼───────┐  ┌──────────────┐  │
│  │ Reporter Agent │  │ Agent Memory   │  │Integration   │  │
│  │                │  │  & Context     │  │   Agent      │  │
│  │ - PDF Reports  │  │                │  │              │  │
│  │ - Excel Export │  │ - Task History │  │ - API Calls  │  │
│  │ - Visualizations│ │ - Learning     │  │ - Data Sync  │  │
│  └────────────────┘  └────────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 3.4 Технологическая архитектура

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Web UI     │  │  Mobile UI   │  │   REST API   │      │
│  │ (Phlex+Turbo)│  │  (Adaptive)  │  │   (v1/v2)    │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   Application Layer                          │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Ruby on Rails 8.1 Controllers                │   │
│  │  - Robots, Tasks, Documents, Reports, Integrations   │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Business Logic Services                 │   │
│  │  - Agent Orchestration, Task Processing, Analytics   │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                      Data Layer                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Active Record Models                         │   │
│  │  - Robot, Agent, Task, Document, User, etc.          │   │
│  └────────────────┬─────────────────────────────────────┘   │
│                   │                                          │
│  ┌────────────────▼─────────────────────────────────────┐   │
│  │         Database (PostgreSQL / SQLite)               │   │
│  │  - Primary Data Store                                │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                        │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Solid   │  │  Solid   │  │  Solid   │  │  Active  │   │
│  │  Queue   │  │  Cache   │  │  Cable   │  │ Storage  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. Требования к системе

### 4.1 Функциональные требования (FR)

#### FR-SYS: Системные требования

| ID | Требование | Приоритет | Статус |
|----|-----------|-----------|--------|
| **FR-SYS-001** | Система ДОЛЖНА поддерживать регистрацию и управление роботами и ИИ-агентами | Критический | ✅ Реализовано |
| **FR-SYS-002** | Система ДОЛЖНА обеспечивать создание и выполнение заданий для роботов и агентов | Критический | ✅ Реализовано |
| **FR-SYS-003** | Система ДОЛЖНА поддерживать управление документами с полнотекстовым поиском | Высокий | ✅ Реализовано |
| **FR-SYS-004** | Система ДОЛЖНА обеспечивать планирование и учет технического обслуживания | Высокий | ✅ Реализовано |
| **FR-SYS-005** | Система ДОЛЖНА предоставлять аналитические дашборды с ключевыми метриками | Средний | ✅ Реализовано |
| **FR-SYS-006** | Система ДОЛЖНА поддерживать экспорт данных в форматы PDF, Excel, KML | Средний | ✅ Реализовано |

#### FR-AGT: Требования к агентной системе

| ID | Требование | Приоритет | Статус |
|----|-----------|-----------|--------|
| **FR-AGT-001** | Система ДОЛЖНА поддерживать создание специализированных ИИ-агентов (Analyzer, Transformer, Validator, Reporter, Integration) | Критический | ✅ Реализовано |
| **FR-AGT-002** | Мета-слой ДОЛЖЕН автоматически распределять задачи между агентами на основе их возможностей и загрузки | Критический | ✅ Реализовано |
| **FR-AGT-003** | Система ДОЛЖНА отслеживать статус и производительность каждого агента через heartbeat-мониторинг | Критический | ✅ Реализовано |
| **FR-AGT-004** | Verification Layer ДОЛЖЕН валидировать результаты работы агентов и переназначать задачи при ошибках | Критический | ✅ Реализовано |
| **FR-AGT-005** | Система ДОЛЖНА поддерживать контекстную память агентов для обучения и адаптации | Высокий | ✅ Реализовано |
| **FR-AGT-006** | Агенты ДОЛЖНЫ иметь возможность взаимодействовать друг с другом для решения комплексных задач | Высокий | ✅ Реализовано |

#### FR-UI: Требования к интерфейсам

| ID | Требование | Приоритет | Статус |
|----|-----------|-----------|--------|
| **FR-UI-001** | Web UI ДОЛЖЕН использовать компонентную архитектуру на базе Phlex | Критический | ✅ Реализовано |
| **FR-UI-002** | UI ДОЛЖЕН поддерживать responsive дизайн для мобильных устройств | Высокий | ✅ Реализовано |
| **FR-UI-003** | Интерфейс ДОЛЖЕН обеспечивать real-time обновления через Turbo Streams | Высокий | ✅ Реализовано |
| **FR-UI-004** | Система ДОЛЖНА поддерживать русский и английский языки интерфейса | Средний | 🔄 В работе |

#### FR-API: Требования к API

| ID | Требование | Приоритет | Статус |
|----|-----------|-----------|--------|
| **FR-API-001** | Система ДОЛЖНА предоставлять RESTful API для всех основных операций | Критический | ✅ Реализовано |
| **FR-API-002** | API ДОЛЖЕН поддерживать аутентификацию через JWT токены | Критический | ✅ Реализовано |
| **FR-API-003** | API ДОЛЖЕН обеспечивать версионирование (v1, v2) | Высокий | ✅ Реализовано |

#### FR-SEC: Требования безопасности

| ID | Требование | Приоритет | Статус |
|----|-----------|-----------|--------|
| **FR-SEC-001** | Система ДОЛЖНА поддерживать многофакторную аутентификацию (2FA) | Критический | ✅ Реализовано |
| **FR-SEC-002** | Система ДОЛЖНА логировать все критические операции для аудита | Критический | ✅ Реализовано |

### 4.2 Нефункциональные требования (NFR)

#### NFR-PER: Производительность

| ID | Требование | Целевое значение | Измерение |
|----|-----------|------------------|-----------|
| **NFR-PER-001** | Время отклика Web UI | < 1 сек (P99) | Response Time |
| **NFR-PER-002** | Время отклика API | < 500 мс (P99) | Response Time |
| **NFR-PER-003** | Пропускная способность | 100 RPS на инстанс | Throughput |
| **NFR-PER-004** | Одновременные пользователи | До 1000 concurrent users | Load Testing |

#### NFR-REL: Надежность

| ID | Требование | Целевое значение | Измерение |
|----|-----------|------------------|-----------|
| **NFR-REL-001** | Uptime системы | 99.5% | Availability |
| **NFR-REL-002** | RTO (Recovery Time Objective) | < 4 часа | Recovery Time |
| **NFR-REL-003** | RPO (Recovery Point Objective) | < 1 час | Data Loss |
| **NFR-REL-004** | MTBF (Mean Time Between Failures) | > 720 часов | Reliability |

#### NFR-SEC: Безопасность

| ID | Требование | Стандарт | Проверка |
|----|-----------|----------|----------|
| **NFR-SEC-001** | Шифрование данных в transit | TLS 1.3 | SSL Labs A+ |
| **NFR-SEC-002** | Шифрование данных at rest | AES-256 | Encryption Check |
| **NFR-SEC-003** | Защита от OWASP Top 10 | 100% покрытие | Security Scan |
| **NFR-SEC-004** | Соответствие ISO 27001 | Базовый уровень | Audit |

#### NFR-SCA: Масштабируемость

| ID | Требование | Целевое значение | Метод |
|----|-----------|------------------|-------|
| **NFR-SCA-001** | Горизонтальное масштабирование | До 10 инстансов | Kubernetes/Kamal |
| **NFR-SCA-002** | Количество агентов | До 100+ одновременно | Agent Registry |
| **NFR-SCA-003** | Количество задач | До 10000+ одновременно | Task Queue |
| **NFR-SCA-004** | Размер базы данных | До 1 TB | Database Scaling |

---

## 5. Технологический стек

### 5.1 Backend

| Компонент | Технология | Версия | Назначение |
|-----------|-----------|--------|------------|
| **Framework** | Ruby on Rails | 8.1.0 | Основной веб-фреймворк |
| **Language** | Ruby | 3.3.6 | Язык программирования |
| **Web Server** | Puma | 7.1.0+ | HTTP сервер |
| **Database (Dev)** | SQLite3 | 3.x | База данных для разработки |
| **Database (Prod)** | PostgreSQL | 14+ | Продакшен база данных |
| **Queue System** | Solid Queue | Rails 8 | Система фоновых задач |
| **Caching** | Solid Cache | Rails 8 | Кэширование данных |
| **WebSockets** | Solid Cable | Rails 8 | Real-time коммуникации |

### 5.2 Frontend

| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| **View Layer** | Phlex | Ruby DSL для HTML компонентов |
| **UI Components** | PhlexyUI | DaisyUI компоненты для Phlex |
| **CSS Framework** | Tailwind CSS + DaisyUI | Стилизация и UI компоненты |
| **JavaScript Framework** | Stimulus | Минималистичные JS контроллеры |
| **SPA-like Experience** | Turbo (Hotwire) | Навигация без полной перезагрузки |
| **JS Modules** | Importmap Rails | Управление JS без сборщика |

### 5.3 ИИ и LLM интеграции

| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| **OpenAI** | ruby-openai | GPT-3.5, GPT-4, GPT-4o интеграция |
| **Anthropic** | anthropic-sdk | Claude 3 интеграция |
| **HTTP Client** | httparty | Универсальный API клиент |
| **LLM Metrics** | Custom Models | Трекинг использования и затрат |

### 5.4 Аутентификация и авторизация

| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| **Authentication** | Devise | Аутентификация пользователей |
| **2FA** | Devise Two Factor | Двухфакторная аутентификация |
| **Authorization** | Pundit | Policy-based авторизация |
| **JWT** | jwt gem | API токены |
| **Password Hashing** | bcrypt | Безопасное хеширование |

### 5.5 Безопасность

| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| **Rate Limiting** | Rack Attack | Защита от DDoS |
| **Security Headers** | Secure Headers | Настройка HTTP заголовков |
| **Secrets Management** | Rails Credentials | Безопасное хранение секретов |

### 5.6 Документы и отчеты

| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| **PDF Generation** | Prawn + Prawn Table | Генерация PDF документов |
| **Excel Export** | Caxlsx + Caxlsx Rails | Генерация Excel файлов |
| **PDF Parsing** | PDF Reader | Чтение и обработка PDF |
| **Full-text Search** | pg_search | Полнотекстовый поиск |

### 5.7 Развертывание и DevOps

| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| **Containerization** | Docker | Контейнеризация приложения |
| **Orchestration** | Kamal | Развертывание без Kubernetes |
| **HTTP Acceleration** | Thruster | Кэширование и сжатие для Puma |
| **CI/CD** | GitHub Actions | Автоматизация тестирования и деплоя |

### 5.8 Тестирование

| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| **Unit Tests** | Minitest / RSpec | Тестирование моделей и сервисов |
| **Integration Tests** | Capybara | Интеграционное тестирование |
| **System Tests** | Selenium WebDriver | E2E тестирование |
| **Factories** | Factory Bot | Создание тестовых данных |
| **Fixtures** | Faker | Генерация фейковых данных |
| **HTTP Mocking** | WebMock + VCR | Мокирование HTTP запросов |
| **Code Coverage** | SimpleCov | Анализ покрытия кода |
| **Security Scan** | Brakeman | Статический анализ безопасности |
| **Dependency Audit** | Bundler Audit | Аудит уязвимостей в зависимостях |

---

## 6. Модель данных

### 6.1 Основные сущности

#### 6.1.1 Доменная модель агентной системы

```
┌─────────────────────────────────────────────────────────────┐
│                    Agent Domain Model                        │
│                                                              │
│  ┌──────────────┐                    ┌──────────────┐       │
│  │   Agent      │                    │  AgentTask   │       │
│  ├──────────────┤                    ├──────────────┤       │
│  │ id           │1                  *│ id           │       │
│  │ type (STI)   │────────────────────│ agent_id     │       │
│  │ name         │                    │ task_type    │       │
│  │ status       │                    │ status       │       │
│  │ capabilities │                    │ priority     │       │
│  │ load_score   │                    │ input_data   │       │
│  │ success_rate │                    │ output_data  │       │
│  └──────────────┘                    │ retry_count  │       │
│         │                            │ quality_score│       │
│         │                            └──────┬───────┘       │
│         │                                   │               │
│  ┌──────▼─────────┐                 ┌──────▼────────┐      │
│  │ Agent Types:   │                 │ LLM Request   │      │
│  │ - AnalyzerAgent│                 ├───────────────┤      │
│  │ - TransformerAgent               │ id            │      │
│  │ - ValidatorAgent                 │ agent_task_id │      │
│  │ - ReporterAgent                  │ provider      │      │
│  │ - IntegrationAgent               │ model         │      │
│  └────────────────┘                 │ prompt_tokens │      │
│                                     │ cost          │      │
│  ┌──────────────┐                  └───────────────┘      │
│  │AgentCollaboration                                       │
│  ├──────────────┤                  ┌───────────────┐      │
│  │ id           │                  │OrchestratorEvent     │
│  │ agent_task_id│                  ├───────────────┤      │
│  │ primary_agent_id                │ id            │      │
│  │ participating_agents            │ event_type    │      │
│  │ collaboration_type              │ agent_id      │      │
│  │ status       │                  │ agent_task_id │      │
│  │ consensus_results               │ severity      │      │
│  └──────────────┘                  │ message       │      │
│                                    └───────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

#### 6.1.2 Доменная модель робототехники

```
┌─────────────────────────────────────────────────────────────┐
│                  Robotics Domain Model                       │
│                                                              │
│  ┌──────────────┐                    ┌──────────────┐       │
│  │    Robot     │                    │  RobotTask   │       │
│  ├──────────────┤                    ├──────────────┤       │
│  │ id           │1                  *│ id           │       │
│  │ manufacturer │────────────────────│ robot_id     │       │
│  │ model        │                    │ task_number  │       │
│  │ serial_number│                    │ status       │       │
│  │ status       │                    │ planned_date │       │
│  │ capabilities │                    │ operator_id  │       │
│  │ specifications                    │ purpose      │       │
│  └──────┬───────┘                    │ location     │       │
│         │                            └──────┬───────┘       │
│         │                                   │               │
│  ┌──────▼───────┐                   ┌──────▼────────┐      │
│  │  Document    │                   │TelemetryData  │      │
│  ├──────────────┤                   ├───────────────┤      │
│  │ id           │                   │ id            │      │
│  │ robot_id     │                   │ robot_id      │      │
│  │ title        │                   │ task_id       │      │
│  │ category     │                   │ recorded_at   │      │
│  │ file         │                   │ latitude      │      │
│  └──────────────┘                   │ longitude     │      │
│                                     │ sensors       │      │
│  ┌──────────────┐                  └───────────────┘      │
│  │MaintenanceRecord                                        │
│  ├──────────────┤                  ┌───────────────┐      │
│  │ id           │                  │InspectionReport      │
│  │ robot_id     │                  ├───────────────┤      │
│  │ maintenance_type                │ id            │      │
│  │ scheduled_date                  │ task_id       │      │
│  │ completed_date                  │ report_number │      │
│  │ technician_id│                  │ findings      │      │
│  │ description  │                  │ recommendations      │
│  └──────────────┘                  │ photos        │      │
│                                    │ videos        │      │
│                                    └───────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

#### 6.1.3 Доменная модель пользователей и прав

```
┌─────────────────────────────────────────────────────────────┐
│                  User & Permissions Model                    │
│                                                              │
│  ┌──────────────┐                    ┌──────────────┐       │
│  │     User     │                    │     Role     │       │
│  ├──────────────┤                    ├──────────────┤       │
│  │ id           │      *        *    │ id           │       │
│  │ email        │◄───────────────────┤ name         │       │
│  │ encrypted_password   UserRole     │ description  │       │
│  │ name         │                    └──────┬───────┘       │
│  │ role (enum)  │                           │               │
│  │ otp_required │                           │*              │
│  │ api_token    │                    ┌──────▼────────┐      │
│  │ total_flight_hours                │  Permission   │      │
│  └──────┬───────┘                    ├───────────────┤      │
│         │                            │ id            │      │
│         │1                           │ name          │      │
│  ┌──────▼───────┐                    │ resource      │      │
│  │  Dashboard   │                    │ action        │      │
│  ├──────────────┤                    └───────────────┘      │
│  │ id           │                                           │
│  │ user_id      │                    ┌───────────────┐      │
│  │ name         │                    │  AuditLog     │      │
│  │ configuration│                    ├───────────────┤      │
│  │ widgets      │                    │ id            │      │
│  │ is_public    │                    │ user_id       │      │
│  └──────────────┘                    │ action        │      │
│                                      │ resource_type │      │
│  ┌──────────────┐                    │ resource_id   │      │
│  │ Integration  │                    │ details       │      │
│  ├──────────────┤                    │ ip_address    │      │
│  │ id           │                    └───────────────┘      │
│  │ user_id      │                                           │
│  │ integration_type                                         │
│  │ name         │                                           │
│  │ status       │                                           │
│  │ configuration│                                           │
│  │ credentials  │                                           │
│  └──────────────┘                                           │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 Ключевые модели

#### Robot (Робот)
```ruby
class Robot < ApplicationRecord
  # Физические роботы и роботизированные системы
  has_many :robot_tasks
  has_many :documents
  has_many :maintenance_records
  has_many :telemetry_data

  enum status: { active: 0, maintenance: 1, repair: 2, retired: 3 }

  # JSON поля
  # - capabilities: технические возможности
  # - configuration: текущая конфигурация
  # - specifications: технические характеристики
end
```

#### Agent (ИИ-агент)
```ruby
class Agent < ApplicationRecord
  # Базовый класс для всех ИИ-агентов (STI)
  # Наследники: AnalyzerAgent, TransformerAgent, ValidatorAgent, etc.

  has_many :agent_tasks
  has_many :orchestrator_events
  has_many :primary_collaborations, class_name: 'AgentCollaboration'

  enum status: { idle: 0, busy: 1, offline: 2, error: 3 }

  # Метрики производительности
  # - success_rate: процент успешных задач
  # - load_score: текущая загрузка
  # - average_completion_time: среднее время выполнения
end
```

#### AgentTask (Задача агента)
```ruby
class AgentTask < ApplicationRecord
  belongs_to :agent, optional: true
  has_many :llm_requests
  has_many :orchestrator_events
  has_many :agent_collaborations

  enum status: {
    pending: 0,
    assigned: 1,
    in_progress: 2,
    completed: 3,
    failed: 4,
    cancelled: 5
  }

  # Система приоритетов (1-10, где 10 - наивысший)
  # Retry logic с exponential backoff
  # Quality score (0-100) после verification
end
```

#### RobotTask (Задание робота)
```ruby
class RobotTask < ApplicationRecord
  self.table_name = 'robot_tasks'

  belongs_to :robot
  belongs_to :operator, class_name: 'User', optional: true
  has_one :inspection_report
  has_many :telemetry_data

  enum status: {
    planned: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  # Обратная совместимость
  # Task = RobotTask (для старого кода)
end
```

#### User (Пользователь)
```ruby
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :trackable,
         :two_factor_authenticatable, :two_factor_backupable

  has_many :robots
  has_many :dashboards
  has_many :integrations
  has_many :audit_logs
  has_many :user_roles
  has_many :roles, through: :user_roles

  enum role: { viewer: 0, operator: 1, technician: 2, admin: 3 }

  # API token для внешних интеграций
  # OTP secret для 2FA
  # GDPR compliance поля
end
```

---

## 7. Этапы разработки

### 7.1 Иерархия этапов разработки

Проект A2D2 разделен на **8 основных фаз**, каждая из которых содержит подэтапы и задачи. Каждая фаза создает набор issues для следующей фазы.

```
Phase 1: MBSE Foundation
  └─► Phase 2: Infrastructure
      └─► Phase 3: Meta-Layer
          └─► Phase 4: Agent System
              └─► Phase 5: Business Modules
                  └─► Phase 6: Integrations
                      └─► Phase 7: Testing & QA
                          └─► Phase 8: Deployment & Operations
```

### 7.2 Phase 1: MBSE Foundation (Фундамент системной инженерии)

**Цель**: Создать полную спецификацию системы по стандартам MBSE

**Статус**: ✅ **ЗАВЕРШЕНА**

**Артефакты** (все в папке `docs/phase-1-mbse/`):

1. **01-SR-001-FUNCTIONAL-REQUIREMENTS.md** — Функциональные требования
2. **02-SR-002-NONFUNCTIONAL-REQUIREMENTS.md** — Нефункциональные требования
3. **03-SR-003-INTERFACE-REQUIREMENTS.md** — Требования к интерфейсам
4. **04-SR-004-SECURITY-REQUIREMENTS.md** — Требования безопасности
5. **05-SR-005-OPERATIONAL-REQUIREMENTS.md** — Требования к эксплуатации
6. **06-SR-006-SCALABILITY-REQUIREMENTS.md** — Требования к масштабируемости
7. **07-ARCHITECTURE-DIAGRAMS.md** — 12 архитектурных диаграмм
8. **08-REQUIREMENTS-TRACEABILITY-MATRIX.md** — Матрица трассируемости
9. **09-VERIFICATION-VALIDATION-PLAN.md** — План верификации и валидации

**Требования**:
- ✅ 100+ требований задокументировано
- ✅ 12 архитектурных диаграмм создано
- ✅ 100% трассируемость требований
- ✅ V&V план утвержден

**Issues созданные Phase 1**: Phase 2 Infrastructure issues

---

### 7.3 Phase 2: Infrastructure & DevOps

**Цель**: Создать production-ready инфраструктуру

**Приоритет**: Критический
**Длительность**: 3-4 недели
**Зависимости**: Phase 1 завершена

#### 7.3.1 Подэтапы Phase 2

**Phase 2.1: Production Environment Setup**

Issues:
- ISSUE-2.1.1: Настройка PostgreSQL production базы данных
- ISSUE-2.1.2: Конфигурация Redis для кэширования (опционально)
- ISSUE-2.1.3: Настройка S3-совместимого хранилища для файлов
- ISSUE-2.1.4: Конфигурация production переменных окружения

**Phase 2.2: CI/CD Pipeline**

Issues:
- ISSUE-2.2.1: Настройка GitHub Actions для тестирования
- ISSUE-2.2.2: Автоматический запуск тестов при PR
- ISSUE-2.2.3: Автоматическое развертывание на staging
- ISSUE-2.2.4: Настройка Kamal для production деплоя

**Phase 2.3: Monitoring & Logging**

Issues:
- ISSUE-2.3.1: Интеграция с системой мониторинга (Prometheus/Grafana)
- ISSUE-2.3.2: Настройка логирования (LogRotate, centralized logs)
- ISSUE-2.3.3: Настройка alerting для критических ошибок
- ISSUE-2.3.4: Создание health check endpoints

**Phase 2.4: Security Infrastructure**

Issues:
- ISSUE-2.4.1: Настройка SSL/TLS сертификатов (Let's Encrypt)
- ISSUE-2.4.2: Конфигурация firewall и security groups
- ISSUE-2.4.3: Настройка Rack::Attack для rate limiting
- ISSUE-2.4.4: Настройка SecureHeaders для HTTP headers

**Критерии завершения Phase 2**:
- ✅ Production окружение развернуто и работает
- ✅ CI/CD pipeline автоматизирован
- ✅ Мониторинг и алертинг настроены
- ✅ Прошел security audit

**Issues созданные Phase 2**: Phase 3 Meta-Layer issues

---

### 7.4 Phase 3: Meta-Layer Implementation

**Цель**: Реализовать мета-слой для оркестрации агентов

**Приоритет**: Критический
**Длительность**: 4-5 недель
**Зависимости**: Phase 2 завершена

#### 7.4.1 Подэтапы Phase 3

**Phase 3.1: Orchestrator Core**

Issues:
- ISSUE-3.1.1: Создать базовый Orchestrator service
- ISSUE-3.1.2: Реализовать round-robin стратегию распределения
- ISSUE-3.1.3: Реализовать least-loaded стратегию
- ISSUE-3.1.4: Реализовать capability-match стратегию
- ISSUE-3.1.5: Добавить управление жизненным циклом агентов

**Phase 3.2: Task Queue Manager**

Issues:
- ISSUE-3.2.1: Интегрировать Solid Queue
- ISSUE-3.2.2: Реализовать приоритизацию задач
- ISSUE-3.2.3: Добавить retry logic с exponential backoff
- ISSUE-3.2.4: Реализовать deadline tracking для задач
- ISSUE-3.2.5: Добавить зависимости между задачами

**Phase 3.3: Agent Registry**

Issues:
- ISSUE-3.3.1: Создать AgentRegistry service
- ISSUE-3.3.2: Реализовать heartbeat мониторинг
- ISSUE-3.3.3: Добавить capability tracking
- ISSUE-3.3.4: Реализовать автоматическое обнаружение offline агентов
- ISSUE-3.3.5: Добавить метрики производительности агентов

**Phase 3.4: Verification Layer**

Issues:
- ISSUE-3.4.1: Создать VerificationService
- ISSUE-3.4.2: Реализовать проверку качества результатов
- ISSUE-3.4.3: Добавить автоматическое переназначение при ошибках
- ISSUE-3.4.4: Реализовать quality scoring (0-100)
- ISSUE-3.4.5: Добавить escalation logic для критических задач

**Phase 3.5: Memory Management**

Issues:
- ISSUE-3.5.1: Интегрировать Solid Cache
- ISSUE-3.5.2: Реализовать контекстную память агентов
- ISSUE-3.5.3: Добавить кэширование промежуточных результатов
- ISSUE-3.5.4: Реализовать long-term knowledge storage
- ISSUE-3.5.5: Добавить memory cleanup механизмы

**Критерии завершения Phase 3**:
- ✅ Orchestrator распределяет задачи автоматически
- ✅ Task Queue работает с приоритетами и retry
- ✅ Agent Registry мониторит статус агентов
- ✅ Verification Layer валидирует результаты
- ✅ Memory Management обеспечивает контекст

**Issues созданные Phase 3**: Phase 4 Agent System issues

---

### 7.5 Phase 4: Agent System Implementation

**Цель**: Реализовать специализированных ИИ-агентов

**Приоритет**: Критический
**Длительность**: 5-6 недель
**Зависимости**: Phase 3 завершена

#### 7.5.1 Подэтапы Phase 4

**Phase 4.1: Base Agent Infrastructure**

Issues:
- ISSUE-4.1.1: Создать базовый Agent class с STI
- ISSUE-4.1.2: Реализовать AgentTask модель
- ISSUE-4.1.3: Добавить LLMRequest tracking
- ISSUE-4.1.4: Реализовать AgentCollaboration модель
- ISSUE-4.1.5: Создать OrchestratorEvent модель

**Phase 4.2: Analyzer Agent**

Issues:
- ISSUE-4.2.1: Создать AnalyzerAgent класс
- ISSUE-4.2.2: Реализовать статистический анализ данных
- ISSUE-4.2.3: Добавить детекцию аномалий
- ISSUE-4.2.4: Реализовать профилирование данных
- ISSUE-4.2.5: Добавить трендовый анализ

**Phase 4.3: Transformer Agent**

Issues:
- ISSUE-4.3.1: Создать TransformerAgent класс
- ISSUE-4.3.2: Реализовать трансформацию данных
- ISSUE-4.3.3: Добавить data cleansing операции
- ISSUE-4.3.4: Реализовать конвертацию форматов
- ISSUE-4.3.5: Добавить обогащение данных из внешних источников

**Phase 4.4: Validator Agent**

Issues:
- ISSUE-4.4.1: Создать ValidatorAgent класс
- ISSUE-4.4.2: Реализовать валидацию по бизнес-правилам
- ISSUE-4.4.3: Добавить проверку форматов и ограничений
- ISSUE-4.4.4: Реализовать quality assessment
- ISSUE-4.4.5: Добавить compliance checking

**Phase 4.5: Reporter Agent**

Issues:
- ISSUE-4.5.1: Создать ReporterAgent класс
- ISSUE-4.5.2: Реализовать генерацию PDF отчетов через Prawn
- ISSUE-4.5.3: Добавить генерацию Excel через Caxlsx
- ISSUE-4.5.4: Реализовать создание графиков и визуализаций
- ISSUE-4.5.5: Добавить template-based отчеты

**Phase 4.6: Integration Agent**

Issues:
- ISSUE-4.6.1: Создать IntegrationAgent класс
- ISSUE-4.6.2: Реализовать REST API интеграции
- ISSUE-4.6.3: Добавить GraphQL интеграции
- ISSUE-4.6.4: Реализовать database интеграции
- ISSUE-4.6.5: Добавить webhook поддержку

**Phase 4.7: Agent Collaboration**

Issues:
- ISSUE-4.7.1: Реализовать multi-agent collaboration
- ISSUE-4.7.2: Добавить consensus mechanisms
- ISSUE-4.7.3: Реализовать task delegation между агентами
- ISSUE-4.7.4: Добавить conflict resolution
- ISSUE-4.7.5: Реализовать collaborative learning

**Критерии завершения Phase 4**:
- ✅ Все 5 типов агентов реализованы
- ✅ Агенты могут выполнять задачи автономно
- ✅ Агенты могут взаимодействовать друг с другом
- ✅ LLM интеграции работают корректно
- ✅ Метрики производительности собираются

**Issues созданные Phase 4**: Phase 5 Business Modules issues

---

### 7.6 Phase 5: Business Modules

**Цель**: Реализовать готовые бизнес-модули

**Приоритет**: Высокий
**Длительность**: 4-5 недель
**Зависимости**: Phase 4 завершена

#### 7.6.1 Подэтапы Phase 5

**Phase 5.1: Document Management Module**

Issues:
- ISSUE-5.1.1: Реализовать автоматическую классификацию документов
- ISSUE-5.1.2: Добавить извлечение данных из документов (OCR)
- ISSUE-5.1.3: Реализовать полнотекстовый поиск через pg_search
- ISSUE-5.1.4: Добавить версионирование документов
- ISSUE-5.1.5: Реализовать rights management

**Phase 5.2: Process Automation Module**

Issues:
- ISSUE-5.2.1: Создать Process и ProcessStep модели
- ISSUE-5.2.2: Реализовать visual workflow builder
- ISSUE-5.2.3: Добавить библиотеку готовых блоков
- ISSUE-5.2.4: Реализовать real-time execution monitoring
- ISSUE-5.2.5: Добавить retry и error handling

**Phase 5.3: Analytics Module**

Issues:
- ISSUE-5.3.1: Создать Dashboard модель
- ISSUE-5.3.2: Реализовать data aggregation service
- ISSUE-5.3.3: Добавить интеллектуальную визуализацию
- ISSUE-5.3.4: Реализовать predictive analytics
- ISSUE-5.3.5: Добавить scheduled report generation

**Phase 5.4: Integration Module**

Issues:
- ISSUE-5.4.1: Создать Integration модель
- ISSUE-5.4.2: Реализовать коннекторы к 1C, SAP, Bitrix24
- ISSUE-5.4.3: Добавить универсальный REST/GraphQL адаптер
- ISSUE-5.4.4: Реализовать data transformation pipeline
- ISSUE-5.4.5: Добавить webhook поддержку

**Критерии завершения Phase 5**:
- ✅ Все 4 бизнес-модуля реализованы
- ✅ Модули интегрированы с агентной системой
- ✅ UI интерфейсы созданы (Phlex компоненты)
- ✅ API endpoints документированы
- ✅ Базовые интеграционные тесты пройдены

**Issues созданные Phase 5**: Phase 6 Integrations issues

---

### 7.7 Phase 6: External Integrations

**Цель**: Реализовать интеграции с внешними системами

**Приоритет**: Средний
**Длительность**: 3-4 недели
**Зависимости**: Phase 5 завершена

#### 7.7.1 Подэтапы Phase 6

**Phase 6.1: LLM Providers Integration**

Issues:
- ISSUE-6.1.1: Интегрировать OpenAI (GPT-3.5, GPT-4, GPT-4o)
- ISSUE-6.1.2: Интегрировать Anthropic (Claude 3 Opus, Sonnet, Haiku)
- ISSUE-6.1.3: Интегрировать DeepSeek
- ISSUE-6.1.4: Добавить умную маршрутизацию запросов
- ISSUE-6.1.5: Реализовать cost optimization

**Phase 6.2: Enterprise Systems Integration**

Issues:
- ISSUE-6.2.1: Реализовать 1C коннектор
- ISSUE-6.2.2: Реализовать SAP коннектор
- ISSUE-6.2.3: Реализовать Bitrix24 коннектор
- ISSUE-6.2.4: Реализовать AmoCRM коннектор
- ISSUE-6.2.5: Добавить generic OAuth2 коннектор

**Phase 6.3: Cloud Storage Integration**

Issues:
- ISSUE-6.3.1: Интегрировать Amazon S3
- ISSUE-6.3.2: Интегрировать Yandex Object Storage
- ISSUE-6.3.3: Интегрировать DigitalOcean Spaces
- ISSUE-6.3.4: Добавить automatic failover между провайдерами
- ISSUE-6.3.5: Реализовать file versioning

**Критерии завершения Phase 6**:
- ✅ LLM провайдеры интегрированы и работают
- ✅ Корпоративные системы подключены
- ✅ Облачные хранилища настроены
- ✅ Интеграционные тесты пройдены
- ✅ Документация по интеграциям создана

**Issues созданные Phase 6**: Phase 7 Testing issues

---

### 7.8 Phase 7: Testing & Quality Assurance

**Цель**: Полное тестирование системы

**Приоритет**: Критический
**Длительность**: 3-4 недели
**Зависимости**: Phase 6 завершена

#### 7.8.1 Подэтапы Phase 7

**Phase 7.1: Unit & Integration Testing**

Issues:
- ISSUE-7.1.1: Написать unit тесты для всех моделей (80%+ coverage)
- ISSUE-7.1.2: Написать integration тесты для контроллеров
- ISSUE-7.1.3: Написать тесты для сервисов и background jobs
- ISSUE-7.1.4: Добавить тесты для агентной системы
- ISSUE-7.1.5: Достичь 80%+ code coverage (SimpleCov)

**Phase 7.2: System & E2E Testing**

Issues:
- ISSUE-7.2.1: Написать system тесты для ключевых user flows
- ISSUE-7.2.2: Добавить E2E тесты с Capybara + Selenium
- ISSUE-7.2.3: Реализовать smoke tests для критических функций
- ISSUE-7.2.4: Добавить regression tests
- ISSUE-7.2.5: Создать test data fixtures и factories

**Phase 7.3: Performance Testing**

Issues:
- ISSUE-7.3.1: Провести load testing (JMeter/k6)
- ISSUE-7.3.2: Провести stress testing
- ISSUE-7.3.3: Провести endurance testing (12+ часов)
- ISSUE-7.3.4: Провести spike testing
- ISSUE-7.3.5: Оптимизировать узкие места

**Phase 7.4: Security Testing**

Issues:
- ISSUE-7.4.1: Провести OWASP Top 10 security scan
- ISSUE-7.4.2: Выполнить penetration testing
- ISSUE-7.4.3: Провести dependency vulnerability audit (Bundler Audit)
- ISSUE-7.4.4: Выполнить static code analysis (Brakeman)
- ISSUE-7.4.5: Исправить все critical и high vulnerabilities

**Критерии завершения Phase 7**:
- ✅ 80%+ code coverage достигнуто
- ✅ Все критические баги исправлены
- ✅ Performance тесты пройдены
- ✅ Security аудит пройден
- ✅ Regression тесты проходят успешно

**Issues созданные Phase 7**: Phase 8 Deployment issues

---

### 7.9 Phase 8: Deployment & Operations

**Цель**: Развернуть систему в production

**Приоритет**: Критический
**Длительность**: 2-3 недели
**Зависимости**: Phase 7 завершена

#### 7.9.1 Подэтапы Phase 8

**Phase 8.1: Production Deployment**

Issues:
- ISSUE-8.1.1: Финальная настройка production окружения
- ISSUE-8.1.2: Миграция production базы данных
- ISSUE-8.1.3: Развертывание через Kamal
- ISSUE-8.1.4: Настройка DNS и SSL сертификатов
- ISSUE-8.1.5: Smoke test на production

**Phase 8.2: Monitoring & Alerting**

Issues:
- ISSUE-8.2.1: Настройка production мониторинга
- ISSUE-8.2.2: Конфигурация алертов для критических метрик
- ISSUE-8.2.3: Настройка log aggregation
- ISSUE-8.2.4: Создание runbook для операторов
- ISSUE-8.2.5: Настройка on-call rotation

**Phase 8.3: Documentation & Training**

Issues:
- ISSUE-8.3.1: Завершение user documentation
- ISSUE-8.3.2: Завершение admin documentation
- ISSUE-8.3.3: Создание API documentation (OpenAPI/Swagger)
- ISSUE-8.3.4: Проведение training для операторов
- ISSUE-8.3.5: Создание FAQ и troubleshooting guide

**Phase 8.4: Launch & Support**

Issues:
- ISSUE-8.4.1: Soft launch для ограниченной группы пользователей
- ISSUE-8.4.2: Сбор обратной связи и quick fixes
- ISSUE-8.4.3: Public launch
- ISSUE-8.4.4: Настройка support процессов (GitHub Issues)
- ISSUE-8.4.5: Мониторинг first week в production

**Критерии завершения Phase 8**:
- ✅ Система развернута в production
- ✅ Мониторинг и alerting работают
- ✅ Документация завершена
- ✅ Support процессы настроены
- ✅ Первая неделя в production прошла стабильно

**Issues созданные Phase 8**: Continuous improvement backlog

---

### 7.10 Визуализация потока этапов

```
┌─────────────────────────────────────────────────────────────┐
│                    Development Flow                          │
│                                                              │
│  Phase 1: MBSE Foundation (✅ Completed)                     │
│  ├─ System Requirements                                      │
│  ├─ Architecture Diagrams                                    │
│  ├─ RTM (Traceability Matrix)                               │
│  └─ V&V Plan                                                 │
│      │                                                       │
│      ▼                                                       │
│  Phase 2: Infrastructure (🔄 Next)                           │
│  ├─ Production Environment                                   │
│  ├─ CI/CD Pipeline                                           │
│  ├─ Monitoring & Logging                                     │
│  └─ Security Infrastructure                                  │
│      │                                                       │
│      ▼                                                       │
│  Phase 3: Meta-Layer                                         │
│  ├─ Orchestrator                                             │
│  ├─ Task Queue Manager                                       │
│  ├─ Agent Registry                                           │
│  ├─ Verification Layer                                       │
│  └─ Memory Management                                        │
│      │                                                       │
│      ▼                                                       │
│  Phase 4: Agent System                                       │
│  ├─ Base Agent Infrastructure                                │
│  ├─ Analyzer Agent                                           │
│  ├─ Transformer Agent                                        │
│  ├─ Validator Agent                                          │
│  ├─ Reporter Agent                                           │
│  ├─ Integration Agent                                        │
│  └─ Agent Collaboration                                      │
│      │                                                       │
│      ▼                                                       │
│  Phase 5: Business Modules                                   │
│  ├─ Document Management                                      │
│  ├─ Process Automation                                       │
│  ├─ Analytics                                                │
│  └─ Integration Module                                       │
│      │                                                       │
│      ▼                                                       │
│  Phase 6: External Integrations                              │
│  ├─ LLM Providers                                            │
│  ├─ Enterprise Systems                                       │
│  └─ Cloud Storage                                            │
│      │                                                       │
│      ▼                                                       │
│  Phase 7: Testing & QA                                       │
│  ├─ Unit & Integration                                       │
│  ├─ System & E2E                                             │
│  ├─ Performance Testing                                      │
│  └─ Security Testing                                         │
│      │                                                       │
│      ▼                                                       │
│  Phase 8: Deployment                                         │
│  ├─ Production Deployment                                    │
│  ├─ Monitoring & Alerting                                    │
│  ├─ Documentation                                            │
│  └─ Launch & Support                                         │
│      │                                                       │
│      ▼                                                       │
│  Continuous Improvement                                      │
│  └─ Feature Backlog                                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 8. Процесс развертывания

### 8.1 Локальная разработка

#### 8.1.1 Требования

- Ruby 3.3.6+
- Rails 8.1.0
- SQLite3
- Node.js 18+ (для сборки ассетов)
- Git

#### 8.1.2 Установка

```bash
# 1. Клонировать репозиторий
git clone https://github.com/your-org/a2d2.git
cd a2d2

# 2. Установить зависимости
bundle install

# 3. Настроить базу данных
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# 4. Запустить development сервер
bin/dev  # Запускает и web-сервер и Solid Queue
```

### 8.2 Production развертывание

#### 8.2.1 Требования к серверу

**Минимальные (до 1000 пользователей)**:
- CPU: 2 cores (2.4 GHz+)
- RAM: 4 GB
- Disk: 50 GB SSD
- Network: 10 Mbps
- PostgreSQL 14+

**Рекомендуемые (до 10000 пользователей)**:
- CPU: 4-8 cores (3.0 GHz+)
- RAM: 16 GB
- Disk: 200 GB SSD
- Network: 100 Mbps
- PostgreSQL 14+ с репликацией
- Redis 7+ для кэширования

**Enterprise (50000+ пользователей)**:
- CPU: 8+ cores
- RAM: 32+ GB
- Disk: 500+ GB SSD (RAID)
- Network: 1 Gbps+
- PostgreSQL кластер с репликацией
- Load Balancer (Nginx/HAProxy)
- CDN для статических ассетов

#### 8.2.2 Развертывание с Kamal

```bash
# 1. Настроить Kamal конфигурацию
# Отредактировать config/deploy.yml

# 2. Первоначальная настройка
kamal setup

# 3. Развертывание
kamal deploy

# 4. Проверка статуса
kamal app details

# 5. Просмотр логов
kamal app logs
```

#### 8.2.3 Переменные окружения (Production)

```bash
# Rails
RAILS_ENV=production
SECRET_KEY_BASE=<generate_with_bin_rails_secret>
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2

# Database
DATABASE_URL=postgresql://user:password@host:5432/a2d2_production

# Redis (опционально)
REDIS_URL=redis://localhost:6379/0

# Storage (S3-compatible)
AWS_ACCESS_KEY_ID=<your_key>
AWS_SECRET_ACCESS_KEY=<your_secret>
AWS_REGION=us-east-1
AWS_BUCKET=a2d2-production

# LLM Providers (опционально)
OPENAI_API_KEY=<your_openai_key>
ANTHROPIC_API_KEY=<your_anthropic_key>

# Monitoring (опционально)
SENTRY_DSN=<your_sentry_dsn>
```

---

## 9. Требования к инфраструктуре

### 9.1 Системные требования

| Компонент | Development | Staging | Production |
|-----------|-------------|---------|------------|
| **OS** | macOS/Linux/Windows | Ubuntu 20.04+ | Ubuntu 22.04 LTS |
| **Ruby** | 3.3.6+ | 3.3.6+ | 3.3.6+ |
| **Rails** | 8.1.0 | 8.1.0 | 8.1.0 |
| **Database** | SQLite3 | PostgreSQL 14+ | PostgreSQL 14+ |
| **Web Server** | Puma (dev) | Puma | Puma + Thruster |
| **Reverse Proxy** | - | Nginx (optional) | Nginx/Caddy |
| **Container Runtime** | - | Docker 24+ | Docker 24+ |

### 9.2 Сетевые порты

| Порт | Сервис | Окружение | Доступ |
|------|--------|-----------|--------|
| 3000 | Rails (dev) | Development | Public |
| 80 | HTTP | Production | Public |
| 443 | HTTPS | Production | Public |
| 5432 | PostgreSQL | All | Internal only |
| 6379 | Redis | Production | Internal only |

### 9.3 Требования к производительности

| Метрика | Требование | Метод измерения |
|---------|-----------|-----------------|
| **Response Time (P99)** | < 1 секунда | New Relic / DataDog |
| **API Response Time (P99)** | < 500 мс | Application metrics |
| **Uptime** | 99.5% | Monitoring |
| **Database Query Time (P95)** | < 100 мс | Database monitoring |
| **Background Job Processing** | < 5 минут (P95) | Solid Queue metrics |

### 9.4 Требования к безопасности

| Требование | Реализация | Проверка |
|-----------|------------|----------|
| **TLS/SSL** | TLS 1.3, Let's Encrypt | SSL Labs |
| **Authentication** | Devise + 2FA | Security audit |
| **Authorization** | Pundit (RBAC) | Access control tests |
| **Rate Limiting** | Rack::Attack | Load testing |
| **CSRF Protection** | Rails built-in | Security tests |
| **XSS Protection** | Rails escaping | Security scan |
| **SQL Injection** | Active Record parameterized queries | Brakeman |

---

## 10. Поток создания issues

### 10.1 Автоматическое создание issues для ИИ-агента

Данная спецификация предназначена для использования ИИ-агентом (Claude) для автоматического создания issues в GitHub. Каждая фаза создает issues для следующей фазы.

### 10.2 Шаблон issue для Phase 2

#### Пример: ISSUE-2.1.1

```markdown
# Настройка PostgreSQL production базы данных

**Phase**: 2.1 - Production Environment Setup
**Priority**: Critical
**Estimated Time**: 4-6 hours
**Dependencies**: None

## Описание

Настроить PostgreSQL 14+ базу данных для production окружения с оптимальными параметрами производительности и безопасности.

## Требования

**Функциональные**:
- PostgreSQL 14 или выше установлен и запущен
- База данных `a2d2_production` создана
- Пользователь с ограниченными правами создан
- Connection pooling настроен

**Нефункциональные**:
- Производительность: поддержка до 100 одновременных подключений
- Безопасность: SSL соединения обязательны
- Надежность: daily backup настроен

## Задачи

- [ ] Установить PostgreSQL 14+
- [ ] Создать базу данных `a2d2_production`
- [ ] Создать пользователя с правами на базу
- [ ] Настроить `postgresql.conf` для production
- [ ] Настроить `pg_hba.conf` для SSL
- [ ] Протестировать подключение из Rails
- [ ] Настроить pg_dump для backup
- [ ] Добавить мониторинг метрик PostgreSQL

## Критерии приемки

- ✅ PostgreSQL установлен и запущен
- ✅ Rails успешно подключается к БД
- ✅ SSL соединения работают
- ✅ Backup выполняется автоматически
- ✅ Метрики собираются в monitoring системе

## Ссылки

- Документация PostgreSQL: https://www.postgresql.org/docs/14/
- Rails Database Configuration: https://guides.rubyonrails.org/configuring.html#configuring-a-database
- Требования: MASTER_SPECIFICATION.md Section 9.1

## Следующие issues

После завершения создать:
- ISSUE-2.1.2: Конфигурация Redis для кэширования
```

### 10.3 Автоматизация создания issues

Для автоматического создания issues на основе данной спецификации используйте следующий процесс:

```bash
# 1. ИИ-агент читает MASTER_SPECIFICATION.md
# 2. Извлекает Phase 2 задачи из Section 7.3
# 3. Для каждой задачи создает issue через GitHub API

gh issue create \
  --title "ISSUE-2.1.1: Настройка PostgreSQL production базы данных" \
  --body "$(cat issue-template-2.1.1.md)" \
  --label "phase-2,infrastructure,database,priority-critical" \
  --milestone "Phase 2: Infrastructure" \
  --assignee "@me"
```

### 10.4 Иерархия issues

```
Phase 2: Infrastructure & DevOps (Epic)
├── Phase 2.1: Production Environment Setup
│   ├── ISSUE-2.1.1: PostgreSQL setup
│   ├── ISSUE-2.1.2: Redis setup
│   ├── ISSUE-2.1.3: S3 storage setup
│   └── ISSUE-2.1.4: Environment variables
├── Phase 2.2: CI/CD Pipeline
│   ├── ISSUE-2.2.1: GitHub Actions setup
│   ├── ISSUE-2.2.2: PR tests automation
│   ├── ISSUE-2.2.3: Staging auto-deploy
│   └── ISSUE-2.2.4: Kamal production deploy
├── Phase 2.3: Monitoring & Logging
│   ├── ISSUE-2.3.1: Prometheus/Grafana integration
│   ├── ISSUE-2.3.2: Logging setup
│   ├── ISSUE-2.3.3: Alerting configuration
│   └── ISSUE-2.3.4: Health checks
└── Phase 2.4: Security Infrastructure
    ├── ISSUE-2.4.1: SSL/TLS certificates
    ├── ISSUE-2.4.2: Firewall configuration
    ├── ISSUE-2.4.3: Rack::Attack setup
    └── ISSUE-2.4.4: SecureHeaders configuration
```

---

## 11. Критерии приемки

### 11.1 Критерии приемки всего проекта

| Категория | Критерий | Метод проверки | Статус |
|-----------|----------|----------------|--------|
| **Функциональность** | Все функциональные требования реализованы | Manual testing + automated tests | Pending |
| **Производительность** | P99 response time < 1 sec | Load testing | Pending |
| **Надежность** | Uptime 99.5% | Monitoring (30 дней) | Pending |
| **Безопасность** | OWASP Top 10 пройдено | Security scan | Pending |
| **Масштабируемость** | Поддержка 100+ агентов | Load testing | Pending |
| **Документация** | Вся документация завершена | Document review | Pending |
| **Тестирование** | 80%+ code coverage | SimpleCov | Pending |

### 11.2 Критерии приемки по фазам

#### Phase 2: Infrastructure

- ✅ Production окружение развернуто
- ✅ CI/CD pipeline автоматизирован
- ✅ Мониторинг работает
- ✅ Security audit пройден

#### Phase 3: Meta-Layer

- ✅ Orchestrator распределяет задачи
- ✅ Task Queue работает с приоритетами
- ✅ Agent Registry мониторит агентов
- ✅ Verification Layer валидирует результаты

#### Phase 4: Agent System

- ✅ Все 5 типов агентов реализованы
- ✅ Агенты выполняют задачи автономно
- ✅ Агенты взаимодействуют друг с другом
- ✅ LLM интеграции работают

#### Phase 5: Business Modules

- ✅ Все 4 модуля реализованы
- ✅ UI интерфейсы созданы
- ✅ API endpoints работают
- ✅ Integration tests пройдены

#### Phase 6: Integrations

- ✅ LLM провайдеры интегрированы
- ✅ Enterprise системы подключены
- ✅ Cloud storage настроен
- ✅ Integration tests пройдены

#### Phase 7: Testing

- ✅ 80%+ code coverage
- ✅ Performance tests пройдены
- ✅ Security audit пройден
- ✅ Regression tests успешны

#### Phase 8: Deployment

- ✅ Production развертывание завершено
- ✅ Monitoring работает
- ✅ Документация завершена
- ✅ Support процессы настроены

---

## 12. Приложения

### 12.1 Приложение A: Список всех моделей

#### Модели агентной системы
- `Agent` (STI: AnalyzerAgent, TransformerAgent, ValidatorAgent, ReporterAgent, IntegrationAgent)
- `AgentTask`
- `AgentCollaboration`
- `AgentCoordination`
- `LlmRequest`
- `LlmUsageSummary`
- `OrchestratorEvent`

#### Модели робототехники
- `Robot`
- `RobotTask` (alias Task)
- `TelemetryData`
- `MaintenanceRecord`
- `InspectionReport`

#### Модели документации
- `Document`

#### Модели пользователей и прав
- `User`
- `Role`
- `Permission`
- `UserRole`
- `RolePermission`
- `AuditLog`
- `TokenBlacklist`

#### Модели бизнес-процессов
- `Process`
- `ProcessStep`
- `ProcessExecution`
- `ProcessStepExecution`

#### Модели интеграций
- `Integration`
- `IntegrationLog`

#### Модели отчетности
- `Report`
- `Dashboard`
- `Metric`

#### Модели N8N workflow
- `Workflow`
- `WorkflowNode`
- `WorkflowConnection`
- `WorkflowExecution`

#### Модели агро-платформы (опционально)
- `Farm`
- `Crop`
- `FieldZone`
- `WeatherData`
- `RemoteSensingData`
- `Equipment`
- `AgroAgent`
- `AgroTask`
- `DecisionSupport`
- `RiskAssessment`
- `SimulationResult`
- `PlantProductionModel`
- `LogisticsOrder`
- `ProcessingBatch`
- `MarketOffer`
- `SmartContract`

#### Модели электронных таблиц
- `Spreadsheet`
- `Sheet`
- `Row`
- `Cell`
- `Collaborator`

### 12.2 Приложение B: Список всех контроллеров

#### Основные контроллеры
- `ApplicationController`
- `HomeController`
- `DashboardsController`

#### Контроллеры роботов
- `RobotsController`
- `TasksController` (RobotTasksController)
- `MaintenanceRecordsController`
- `InspectionReportsController`
- `TelemetryDataController`

#### Контроллеры агентов
- `AgentsController`
- `AgentTasksController`
- `AgentCollaborationsController`

#### Контроллеры документов
- `DocumentsController`

#### Контроллеры пользователей
- `Users::RegistrationsController` (Devise)
- `Users::SessionsController` (Devise)
- `Users::PasswordsController` (Devise)
- `UsersController`
- `RolesController`

#### Контроллеры процессов
- `ProcessesController`
- `ProcessExecutionsController`

#### Контроллеры интеграций
- `IntegrationsController`
- `IntegrationLogsController`

#### Контроллеры отчетов
- `ReportsController`
- `MetricsController`

#### API контроллеры (namespace /api/v1/)
- `Api::V1::RobotsController`
- `Api::V1::TasksController`
- `Api::V1::AuthController`
- `Api::V1::AgentsController`
- `Api::V1::AgentTasksController`

### 12.3 Приложение C: Список всех сервисов

#### Orchestration Services
- `OrchestratorService` — центральный координатор
- `TaskQueueManager` — управление очередью задач
- `AgentRegistry` — реестр агентов
- `VerificationService` — проверка качества
- `MemoryManager` — управление памятью

#### Agent Services
- `AgentExecutionService` — выполнение задач агентами
- `AgentCollaborationService` — координация между агентами
- `LlmProviderService` — взаимодействие с LLM провайдерами

#### Business Services
- `DocumentProcessingService` — обработка документов
- `ProcessExecutionService` — выполнение бизнес-процессов
- `ReportGenerationService` — генерация отчетов
- `IntegrationService` — управление интеграциями

### 12.4 Приложение D: Ссылки на документацию

#### Внутренняя документация проекта
- `README.md` — основной README
- `SPECIFICATION.md` — техническая спецификация
- `CLAUDE.md` — требования к языку и стеку
- `CONTRIBUTING.md` — руководство для контрибьюторов
- `docs/phase-1-mbse/` — MBSE документация (9 файлов)
- `docs/phase-2-infrastructure/` — Infrastructure документация
- `docs/TASK_MANAGEMENT_ARCHITECTURE.md` — архитектура управления задачами
- `docs/API_AUTH.md` — API аутентификация
- `docs/TESTING_STRATEGY.md` — стратегия тестирования

#### Внешние ресурсы
- Ruby on Rails Guides: https://guides.rubyonrails.org/
- Phlex Documentation: https://www.phlex.fun/
- DaisyUI Components: https://daisyui.com/
- Kamal Deployment: https://kamal-deploy.org/
- PostgreSQL Documentation: https://www.postgresql.org/docs/

---

## 📝 История изменений

| Версия | Дата | Автор | Изменения |
|--------|------|-------|-----------|
| 1.0 | 28 октября 2025 | AI Team | Начальная версия |
| 2.0 | 30 октября 2025 | Claude Code | Полная ревизия с иерархией этапов и процессом создания issues |

---

## ✅ Утверждение документа

Этот документ является **главной спецификацией проекта A2D2** и служит основой для:

1. **Разворачивания проекта в новом репозитории**
2. **Автоматического создания issues ИИ-агентом**
3. **Планирования и контроля этапов разработки**
4. **Документирования архитектуры и требований**

**Статус**: ✅ **Утверждено для использования**

**Для использования ИИ-агентом Claude**:
Этот документ содержит всю необходимую информацию для автоматического создания issues на GitHub. Каждая Phase детально описана с подэтапами и конкретными задачами. Используйте Section 7 (Этапы разработки) для извлечения задач и Section 10 (Поток создания issues) для шаблонов.

---

**Конец документа**
