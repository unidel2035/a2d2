# DEPLOY-004: Процедуры Отката

**Статус**: Завершено
**Версия**: 1.0
**Последнее Обновление**: 2025-10-28

## Обзор

Комплексные процедуры отката для платформы A2D2 для быстрого возврата проблемных развертываний.

## Матрица Решений об Откате

| Критичность | Симптомы | Действие | Временные Рамки |
|-------------|----------|----------|-----------------|
| **Критическая** | Сервис недоступен, ошибки 500, потеря данных | Немедленный откат | < 5 минут |
| **Высокая** | >5% частота ошибок, серьезная деградация производительности | Быстрый откат | < 15 минут |
| **Средняя** | <5% частота ошибок, незначительные баги | Оценить, затем откат или hotfix | < 30 минут |
| **Низкая** | Проблемы UI, некритичные баги | Hotfix в следующем развертывании | Следующий релиз |

## Команды Быстрого Отката

### Откат Приложения

```bash
# Откат одной командой
/var/www/a2d2/scripts/rollback.sh

# Или вручную:
cd /var/www/a2d2
ln -nfs releases/PREVIOUS_VERSION current
sudo systemctl reload a2d2-web a2d2-worker
```

### Откат Базы Данных

```bash
# Откат последней миграции
cd /var/www/a2d2/current
RAILS_ENV=production bundle exec rails db:rollback

# Откат конкретной версии
RAILS_ENV=production bundle exec rails db:migrate:down VERSION=20251028120000
```

## Автоматизированный Скрипт Отката

```bash
#!/bin/bash
# File: /var/www/a2d2/scripts/rollback.sh

set -e

APP_ROOT="/var/www/a2d2"
CURRENT_LINK="$APP_ROOT/current"
RELEASES_DIR="$APP_ROOT/releases"
BACKUP_DIR="/var/backups/a2d2"

# Get versions
CURRENT=$(readlink "$CURRENT_LINK" | xargs basename)
PREVIOUS=$(ls -t "$RELEASES_DIR" | grep -v "$CURRENT" | head -1)

echo "========================================="
echo "  A2D2 ROLLBACK PROCEDURE"
echo "========================================="
echo "Current version: $CURRENT"
echo "Rolling back to: $PREVIOUS"
echo ""
read -p "Continue? (yes/no): " confirm

[ "$confirm" != "yes" ] && exit 0

# 1. Backup current logs
echo "Backing up logs..."
tar -czf "$BACKUP_DIR/logs-$CURRENT-$(date +%Y%m%d_%H%M%S).tar.gz" \
    "$APP_ROOT/shared/log"

# 2. Switch to previous release
echo "Switching to previous release..."
ln -nfs "$RELEASES_DIR/$PREVIOUS" "$CURRENT_LINK"

# 3. Database rollback (if needed)
echo "Checking for database rollbacks..."
cd "$CURRENT_LINK"
# Note: Only rollback if migration exists in current but not in previous
if RAILS_ENV=production bundle exec rails db:rollback:check 2>/dev/null; then
    read -p "Rollback database? (yes/no): " db_confirm
    if [ "$db_confirm" = "yes" ]; then
        RAILS_ENV=production bundle exec rails db:rollback
    fi
fi

# 4. Restart services
echo "Restarting services..."
sudo systemctl reload a2d2-worker
sudo systemctl reload a2d2-web

# 5. Health check
echo "Running health checks..."
sleep 10
if curl -f http://localhost:3000/health; then
    echo "✅ Rollback successful!"
else
    echo "❌ Health check failed!"
    exit 1
fi

echo "Rollback completed: $PREVIOUS is now active"
```

## Сценарии Отката

### Сценарий 1: Проблема с Кодом Приложения

**Симптомы**: Сбои, ошибки 500, исключения

**Решение**:
```bash
# 1. Откат приложения
./scripts/rollback.sh

# 2. Проверка работоспособности
curl http://localhost:3000/health

# 3. Мониторинг логов
tail -f log/production.log
```

### Сценарий 2: Проблема с Миграцией Базы Данных

**Симптомы**: Ошибки базы данных, сбои миграции

**Решение**:
```bash
# 1. Откат миграции
cd /var/www/a2d2/current
RAILS_ENV=production bundle exec rails db:rollback

# 2. Проверка состояния базы данных
RAILS_ENV=production bundle exec rails db:migrate:status

# 3. Перезапуск приложения
sudo systemctl restart a2d2-web a2d2-worker
```

### Сценарий 3: Деградация Производительности

**Симптомы**: Медленное время отклика, высокая загрузка CPU/памяти

**Решение**:
```bash
# 1. Сбор метрик
./scripts/capture-diagnostics.sh

# 2. Откат если серьезно
./scripts/rollback.sh

# 3. Анализ позже
less /var/log/a2d2/diagnostics-*.log
```

### Сценарий 4: Повреждение Данных

**Симптомы**: Недействительные данные, отсутствующие записи

**Решение**:
```bash
# 1. НЕМЕДЛЕННО ОСТАНОВИТЬ ВСЕ СЕРВИСЫ
sudo systemctl stop a2d2-web a2d2-worker

# 2. Восстановить базу данных из резервной копии
./scripts/restore-from-backup.sh /var/backups/postgresql/latest.dump

# 3. Откат приложения
./scripts/rollback.sh

# 4. Исследовать первопричину
# НЕ РАЗВЕРТЫВАТЬ повторно до выявления проблемы
```

## Процедуры Восстановления Базы Данных

### Полное Восстановление Базы Данных

```bash
#!/bin/bash
# File: scripts/restore-from-backup.sh

BACKUP_FILE=$1
DB_NAME="a2d2_production"

# Stop application
sudo systemctl stop a2d2-web a2d2-worker

# Terminate connections
sudo -u postgres psql << EOF
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();
EOF

# Drop and recreate
sudo -u postgres psql << EOF
DROP DATABASE IF EXISTS ${DB_NAME};
CREATE DATABASE ${DB_NAME};
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO a2d2_user;
EOF

# Restore
pg_restore -h localhost -U a2d2_user -d $DB_NAME -v "$BACKUP_FILE"

# Start application
sudo systemctl start a2d2-worker a2d2-web
```

### Восстановление на Момент Времени (PITR)

```bash
# Восстановление на конкретный момент времени
pg_restore_pitr --target-time="2025-10-28 14:30:00" \
    --backup-dir=/var/backups/postgresql/base \
    --wal-dir=/var/backups/postgresql/wal
```

## Мониторинг Во Время Отката

```bash
# Терминал 1: Логи приложения
tail -f /var/www/a2d2/shared/log/production.log

# Терминал 2: Системные логи
journalctl -u a2d2-web -u a2d2-worker -f

# Терминал 3: Логи Nginx
tail -f /var/log/nginx/error.log

# Терминал 4: Активность базы данных
watch -n 1 'sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;"'
```

## Действия После Отката

1. **Отчет об Инциденте**: Задокументировать что произошло
2. **Анализ Первопричин**: Определить почему развертывание не удалось
3. **Исправление**: Подготовить надлежащее исправление
4. **Тестирование**: Тщательно протестировать исправление на staging
5. **Повторное Развертывание**: Когда готово, развертывать с осторожностью

## Тестирование Отката

### Регулярные Учения

```bash
# Скрипт ежемесячных учений отката
#!/bin/bash
# File: scripts/test-rollback.sh

echo "Starting rollback drill..."

# Deploy canary version
./scripts/deploy-zero-downtime.sh canary-test

# Wait for health checks
sleep 30

# Perform rollback
./scripts/rollback.sh

# Verify
if curl -f http://localhost:3000/health; then
    echo "✅ Rollback drill successful"
else
    echo "❌ Rollback drill failed"
    exit 1
fi
```

Запускать ежемесячно:

```bash
# Добавить в crontab
0 3 1 * * /var/www/a2d2/scripts/test-rollback.sh > /var/log/a2d2/rollback-drill.log 2>&1
```

## Процедуры Экстренного Контакта

Если откат не решает проблему:

1. **Эскалировать** к старшим инженерам
2. **Связаться** с командой инфраструктуры
3. **Включить** режим обслуживания
4. **Сообщить** заинтересованным сторонам

```bash
# Включить режим обслуживания
sudo systemctl stop a2d2-web
sudo cp /var/www/a2d2/public/maintenance.html /var/www/a2d2/public/index.html
```

---

**Версия Документа**: 1.0
**Последнее Обновление**: 2025-10-28
**Сопровождающий**: Команда DevOps A2D2
