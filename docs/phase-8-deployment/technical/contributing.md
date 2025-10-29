# DOC-TECH-004: Руководство по внесению вклада

**Версия**: 1.0
**Последнее обновление**: 2025-10-28

## Добро пожаловать, участники!

Благодарим вас за интерес к внесению вклада в A2D2!

## Начало работы

### Настройка среды разработки

```bash
# Клонирование репозитория
git clone https://github.com/unidel2035/a2d2.git
cd a2d2

# Установка зависимостей
bundle install

# Настройка базы данных
rails db:setup

# Запуск тестов
rails test

# Запуск сервера разработки
./bin/dev
```

### Стиль кода

Мы используем RuboCop для форматирования кода:

```bash
# Проверка стиля кода
bundle exec rubocop

# Автоматическое исправление проблем
bundle exec rubocop -a
```

## Рабочий процесс внесения вклада

1. **Форк** репозитория
2. **Создание** ветки функции: `git checkout -b feature/my-feature`
3. **Внесение** изменений
4. **Тестирование** изменений: `rails test`
5. **Коммит** с понятным сообщением
6. **Push** в ваш форк
7. **Создание** Pull Request

### Формат сообщений коммитов

```
<type>(<scope>): <subject>

<body>

<footer>
```

Типы: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Пример:
```
feat(agents): add DeepSeek integration

Implement DeepSeek API client for agent LLM calls.
Includes rate limiting and fallback support.

Closes #123
```

## Тестирование

### Запуск тестов

```bash
# Все тесты
rails test

# Конкретный файл теста
rails test test/models/document_test.rb

# С покрытием
COVERAGE=true rails test
```

### Написание тестов

```ruby
require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  test "should validate presence of filename" do
    document = Document.new
    assert_not document.valid?
    assert_includes document.errors[:filename], "can't be blank"
  end
end
```

## Ревью кода

Все вклады требуют ревью кода:

- **Качество**: Чистый, читаемый, поддерживаемый код
- **Тесты**: Адекватное покрытие тестами (>80%)
- **Документация**: Обновленная документация для новых функций
- **Стиль**: Соответствует рекомендациям RuboCop
- **Безопасность**: Не вносятся уязвимости

## Запросы функций

Отправляйте запросы функций через [GitHub Issues](https://github.com/unidel2035/a2d2/issues):

1. Проверьте, существует ли уже такая задача
2. Опишите функцию
3. Объясните сценарий использования
4. Добавьте макеты, если применимо

## Отчеты об ошибках

Сообщайте об ошибках через [GitHub Issues](https://github.com/unidel2035/a2d2/issues):

1. Поиск существующих задач
2. Предоставьте понятный заголовок
3. Опишите шаги для воспроизведения
4. Включите сообщения об ошибках
5. Укажите окружение (ОС, версию Ruby и т.д.)

## Документация

Помогите улучшить документацию:

- **Руководства пользователя**: docs/phase-8-deployment/user/
- **Техническая документация**: docs/phase-8-deployment/technical/
- **Документация API**: Обновляйте вместе с изменениями кода

## Сообщество

- **Обсуждения**: [GitHub Discussions](https://github.com/unidel2035/a2d2/discussions)
- **Чат**: Скоро
- **Email**: dev@example.com

## Лицензия

Внося вклад, вы соглашаетесь с тем, что ваш вклад будет лицензирован по лицензии MIT.

---

**Спасибо за ваш вклад в A2D2!**

**Версия документа**: 1.0
**Последнее обновление**: 2025-10-28
