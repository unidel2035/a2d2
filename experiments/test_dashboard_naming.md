# Тест проверки исправления автозагрузки модуля DashboardViews

## Проблема (Issue #138)
Ошибка `NameError: uninitialized constant DashboardController::DashboardViews` возникала при попытке отобразить страницу дашборда.

Rails Zeitwerk autoloader не мог найти модуль `DashboardViews`, потому что:
- Файл находился в `app/views/dashboard/index_view.rb`
- Модуль назывался `DashboardViews` (а не `Dashboard`)
- Zeitwerk ожидал найти модуль `DashboardViews` в директории `app/views/dashboard_views/`

## Решение
Перемещен файл для соответствия конвенции автозагрузки Rails Zeitwerk.

### Изменения:
1. **Структура файлов**
   - Было: `app/views/dashboard/index_view.rb` содержит `module DashboardViews`
   - Стало: `app/views/dashboard_views/index_view.rb` содержит `module DashboardViews`

2. **Контроллер** (без изменений)
   - Использует: `render DashboardViews::IndexView.new, layout: Layouts::DashboardLayout`

3. **Соответствие другим view-модулям**
   - `module Billing` → `app/views/billing/`
   - `module Agents` → `app/views/agents/`
   - `module DashboardViews` → `app/views/dashboard_views/`

## Проверка корректности
- Модель `Dashboard` остается без изменений в `app/models/dashboard.rb`
- Модуль представлений `DashboardViews` теперь в правильной директории
- Контроллер не требует изменений
- Zeitwerk autoloader может правильно загрузить модуль

## Ожидаемый результат
После этих изменений ошибка автозагрузки должна быть устранена, так как:
- Структура файлов соответствует конвенции Zeitwerk
- Путь `app/views/dashboard_views/index_view.rb` → модуль `DashboardViews`
- Нет конфликта с моделью `Dashboard`
