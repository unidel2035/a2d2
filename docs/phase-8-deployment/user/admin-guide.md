# DOC-USER-002: Руководство администратора

**Версия**: 1.0
**Последнее обновление**: 2025-10-28
**Аудитория**: Системные администраторы

## Управление пользователями

### Создание пользователей
```bash
# Через консоль Rails
RAILS_ENV=production rails console
User.create!(email: 'user@example.com', password: 'secure_pass', role: 'user')
```

### Роли и разрешения
- **Admin**: Полный доступ к системе
- **Manager**: Создание/управление процессами, просмотр всех документов
- **User**: Базовый доступ к собственным документам и процессам
- **Viewer**: Доступ только для чтения

### Управление лицензиями
```ruby
# Проверка использования лицензий
License.current_usage
# => { users: 45, max_users: 50, ai_agents: 10, processes: 120 }
```

## Конфигурация системы

### Переменные окружения
```bash
# Основные настройки
RAILS_ENV=production
SECRET_KEY_BASE=<generate_with_rails_secret>

# База данных
DATABASE_URL=postgresql://user:pass@host:5432/db
DATABASE_REPLICA_URL=postgresql://user:pass@replica:5432/db

# Redis
REDIS_URL=redis://:password@host:6379/0
REDIS_CACHE_URL=redis://:password@host:6379/1

# LLM API
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
DEEPSEEK_API_KEY=...
```

### Настройки приложения
Расположены в `config/settings.yml`:
```yaml
production:
  max_upload_size: 100 # МБ
  session_timeout: 30 # минуты
  enable_2fa: true
  log_level: info
  retention_days: 90
```

## Резервное копирование и восстановление

### Автоматическое резервное копирование
```bash
# Скрипт ежедневного резервного копирования (запускается через cron)
/var/www/a2d2/scripts/backup-daily.sh
```

### Ручное резервное копирование
```bash
# База данных
pg_dump -U a2d2_user -F c -b a2d2_production > backup.dump

# Файлы
tar -czf uploads-backup.tar.gz /var/www/a2d2/shared/storage
```

### Восстановление
```bash
# База данных
pg_restore -U a2d2_user -d a2d2_production backup.dump

# Файлы
tar -xzf uploads-backup.tar.gz -C /var/www/a2d2/shared/
```

## Мониторинг

### Ключевые метрики
- Время отклика: <2с (95-й процентиль)
- Частота ошибок: <0.1%
- Использование CPU: <70%
- Использование памяти: <80%
- Использование диска: <85%
- Размер очереди: <1000 ожидающих задач

### Доступ к мониторингу
- **Grafana**: http://your-server:3001
- **Prometheus**: http://your-server:9090
- **Логи**: `/var/log/a2d2/`

### Расположение логов
```
/var/log/a2d2/
├── production.log       # Логи приложения
├── web.log             # Логи веб-сервера
├── worker.log          # Логи фоновых задач
└── error.log           # Логи ошибок
```

## Настройка производительности

### Оптимизация базы данных
```sql
-- Очистка базы данных
VACUUM ANALYZE;

-- Переиндексация
REINDEX DATABASE a2d2_production;

-- Проверка медленных запросов
SELECT query, mean_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

### Оптимизация Redis
```bash
# Очистка кэша
redis-cli FLUSHDB

# Проверка памяти
redis-cli INFO memory
```

### Настройка приложения
```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 4 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
```

## Безопасность

### Обновление SSL-сертификата
```bash
# Автоматическое обновление Let's Encrypt
sudo certbot renew --dry-run
```

### Аудит безопасности
```bash
# Запуск сканирования безопасности
bundle exec brakeman -o brakeman-report.html

# Проверка уязвимостей gem-пакетов
bundle exec bundler-audit check --update
```

### Правила брандмауэра
```bash
# Разрешить HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Разрешить SSH (измените порт при необходимости)
sudo ufw allow 22/tcp

# Включить брандмауэр
sudo ufw enable
```

## Устранение неполадок

### Распространенные проблемы

**Проблема**: Приложение не отвечает
```bash
# Проверка сервисов
sudo systemctl status a2d2-web a2d2-worker

# Перезапуск при необходимости
sudo systemctl restart a2d2-web a2d2-worker
```

**Проблема**: Высокая загрузка CPU базы данных
```sql
-- Поиск долго выполняющихся запросов
SELECT pid, age(clock_timestamp(), query_start), query
FROM pg_stat_activity
WHERE state != 'idle' AND query NOT LIKE '%pg_stat_activity%'
ORDER BY query_start;

-- Завершение проблемного запроса
SELECT pg_terminate_backend(pid);
```

**Проблема**: Мало места на диске
```bash
# Проверка использования диска
df -h

# Очистка старых логов
sudo journalctl --vacuum-time=7d

# Очистка старых релизов
cd /var/www/a2d2/releases
ls -t | tail -n +6 | xargs rm -rf
```

## Задачи обслуживания

### Еженедельно
- [ ] Просмотр логов ошибок
- [ ] Проверка места на диске
- [ ] Мониторинг метрик производительности
- [ ] Проверка предупреждений безопасности

### Ежемесячно
- [ ] Применение обновлений безопасности
- [ ] Проверка доступа пользователей
- [ ] Очистка старых данных
- [ ] Тестирование восстановления из резервной копии
- [ ] Обновление документации

### Ежеквартально
- [ ] Аудит безопасности
- [ ] Обзор производительности
- [ ] Планирование мощностей
- [ ] Обучающие сессии для пользователей

## Контакты поддержки

- **Команда DevOps**: devops@example.com
- **Команда безопасности**: security@example.com
- **Дежурный**: +7 (XXX) XXX-XX-XX

---

**Версия документа**: 1.0
**Последнее обновление**: 2025-10-28
