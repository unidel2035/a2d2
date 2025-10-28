# SR-005: Требования к эксплуатации системы A2D2

## Документ системных требований (SRD)
**Версия**: 1.0
**Дата**: 28 октября 2025
**Статус**: Утверждено

---

## 1. Введение

Данный документ определяет требования к эксплуатации, развертыванию, мониторингу и обслуживанию системы A2D2.

---

## 2. Требования к инфраструктуре

### OPR-INF-001: Минимальные требования (Development)

**Отдельный сервер для разработки**:
- CPU: 2 ядра (2.0 GHz+)
- RAM: 4 GB
- Disk: 50 GB SSD
- OS: Ubuntu 20.04 LTS / macOS 10.15+

**Для разработчика локально**:
- RAM: 8 GB минимум для комфортной работы
- CPU: 4+ ядра
- Disk: 20 GB

---

### OPR-INF-002: Рекомендуемые требования (Staging)

- CPU: 4 ядра (2.4 GHz+)
- RAM: 8 GB
- Disk: 100 GB SSD
- Network: 1 Gbps
- OS: Ubuntu 20.04 LTS / Debian 10+

---

### OPR-INF-003: Production требования (100-1000 пользователей)

**Web серверы** (minimum 2 за load balancer):
- CPU: 4 ядра (2.4 GHz+)
- RAM: 8 GB
- Disk: 50 GB SSD

**Database сервер**:
- CPU: 8 ядер (2.6 GHz+)
- RAM: 16 GB
- Disk: 200 GB SSD с RAID 1
- Backup: Отдельный хост для backups

**Load Balancer** (может быть облачный сервис):
- Поддержка SSL termination
- Health checks
- Auto-scaling rules

---

### OPR-INF-004: Enterprise требования (10000+ пользователей)

- Web серверов: 5-10+ за load balancer
- Database: Кластер (Master-Replica)
- Cache: Redis кластер
- Search: ElasticSearch кластер
- Monitoring: Prometheus + Grafana
- CDN: для static assets

---

## 3. Требования к развертыванию

### OPR-DEP-001: Development развертывание

```bash
1. git clone https://github.com/unidel2035/a2d2.git
2. cd a2d2
3. bundle install
4. bin/rails db:setup
5. bin/dev  # Запускает все сервисы локально
```

**Доступ**: http://localhost:3000

---

### OPR-DEP-002: Staging развертывание

- Использовать Kamal для развертывания
- Docker образ строится автоматически
- Database миграции выполняются автоматически
- SSL сертификат (Let's Encrypt)

```bash
kamal setup
kamal deploy
```

---

### OPR-DEP-003: Production развертывание

- Использовать Kamal с несколькими серверами
- Zero-downtime rolling updates
- Database миграции с backups
- Health checks после развертывания

```bash
kamal setup
kamal deploy
kamal app logs  # Мониторить логи
```

---

## 4. Требования к конфигурации

### OPR-CFG-001: Environment переменные

**Обязательные**:
```bash
RAILS_ENV=production
SECRET_KEY_BASE=<сгенерировать: rails secret>
DATABASE_URL=postgresql://user:password@host:5432/a2d2_prod
REDIS_URL=redis://host:6379/0
```

**Опциональные**:
```bash
RAILS_MAX_THREADS=5
WEB_CONCURRENCY=2
RAILS_LOG_LEVEL=info
SENTRY_DSN=<для ошибок>
```

---

### OPR-CFG-002: Конфигурация базы данных

**Development** (SQLite):
```yaml
development:
  adapter: sqlite3
  database: db/development.sqlite3
```

**Production** (PostgreSQL):
```yaml
production:
  adapter: postgresql
  database: a2d2_production
  username: a2d2_user
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] %>
  port: 5432
  pool: 5
  timeout: 5000
```

---

### OPR-CFG-003: Параметры производительности

```yaml
# Puma конфигурация
max_threads: 5
min_threads: 2
threads 2, 5

# Solid Queue конфигурация
workers: 1
poll_interval: 0.1
max_isolation_level: :serializable
```

---

## 5. Требования к резервному копированию

### OPR-BAC-001: Schedule резервных копий

- **Full backup**: Ежедневно в 23:00 UTC
- **Incremental backup**: Каждый час (опционально)
- **Transaction logs**: Каждые 10 минут

---

### OPR-BAC-002: Хранилище резервных копий

- **Локальное**: 7 дней на отдельном диске
- **Cloud**: 30 дней на S3/Azure/GCS
- **Archive**: 1 год в холодном хранилище

---

### OPR-BAC-003: Тестирование восстановления

- **Frequency**: Ежедневно
- **Scope**: Полное восстановление тестовой базы
- **Validation**: Проверка целостности данных
- **Timing**: < 1 часа для восстановления 100GB БД

---

## 6. Требования к мониторингу

### OPR-MON-001: System мониторинг

**Собираемые метрики**:
- CPU usage (target: < 70% avg, < 90% peak)
- Memory usage (target: < 80%)
- Disk usage (target: < 85% free space)
- Network I/O
- Disk I/O

**Инструмент**: Prometheus + Node Exporter

---

### OPR-MON-002: Application мониторинг

**Метрики**:
- Request latency (P50, P95, P99)
- Error rate (target: < 0.5%)
- Throughput (requests/sec)
- Active connections
- Database query time

**Инструмент**: Prometheus client library

---

### OPR-MON-003: Database мониторинг

**Метрики**:
- Connection pool usage
- Query performance (slow queries)
- Transaction duration
- Replication lag (если applicable)
- Backup status

**Инструмент**: PostgreSQL pg_stat_statements

---

### OPR-MON-004: Алерты

**Critical**:
- Disk space < 10%
- CPU > 95% для > 5 минут
- Database недоступна
- Error rate > 5%

**Warning**:
- Disk space < 20%
- CPU > 80%
- P99 latency > 3 сек
- Memory > 85%

**Notification channels**:
- Email
- Slack
- PagerDuty (для critical)

---

## 7. Требования к логированию

### OPR-LOG-001: Application логирование

**Уровни логирования**:
- DEBUG: Детальная информация для отладки
- INFO: Информационные сообщения (старты, события)
- WARN: Предупреждения (deprecated usage, slowness)
- ERROR: Ошибки приложения
- FATAL: Критические ошибки

**Format**:
```
[timestamp] [level] [component] [request_id] message
```

---

### OPR-LOG-002: Ротация логов

- **File rotation**: Ежедневно в 00:00 UTC
- **Compression**: Сжатие логов старше 7 дней
- **Retention**: 90 дней на диске, 1 год в архиве
- **Size limit**: Максимум 100MB на файл

---

### OPR-LOG-003: Централизованное логирование

**Инструмент**: ELK Stack (Elasticsearch, Logstash, Kibana)
или Splunk

**Преимущества**:
- Централизованный поиск
- Долгосрочное хранение
- Аналитика и тренды
- Алертинг на основе логов

---

## 8. Требования к обновлениям

### OPR-UPD-001: Плановые обновления

- **Frequency**: Первый вторник каждого месяца
- **Maintenance window**: 2-4 часа ночью (00:00-04:00 UTC)
- **Notification**: За неделю до обновления
- **Fallback**: Готовый откат к предыдущей версии

---

### OPR-UPD-002: Security патчи

- **Response time**: В течение 24 часов после публикации
- **Out-of-band**: Критические патчи - вне планового schedule
- **Communication**: Уведомление об обновлении

---

### OPR-UPD-003: Dependency обновления

- **Frequency**: Еженедельное сканирование
- **Critical**: Применяются в течение 7 дней
- **High**: В течение 30 дней
- **Medium/Low**: В следующий плановый release

---

## 9. Требования к отказоустойчивости

### OPR-HA-001: High Availability архитектура

- **Multiple web servers**: Минимум 2 за load balancer
- **Database replication**: Master-Replica setup
- **Automatic failover**: Переключение на replica при сбое master
- **Health checks**: Каждые 10 секунд

---

### OPR-HA-002: Graceful shutdown

- **Signal handling**: SIGTERM за 30 сек до shutdown
- **In-flight requests**: Доживают до завершения
- **New connections**: Отклоняются
- **Timeout**: Hard shutdown через 30 сек

---

### OPR-HA-003: Disaster recovery

- **RTO** (Recovery Time Objective): < 4 часов
- **RPO** (Recovery Point Objective): < 1 часа
- **Backup testing**: Ежемесячное тестирование восстановления
- **Documentation**: Detailed runbook для восстановления

---

## 10. Требования к обслуживанию

### OPR-MAINT-001: Регулярные работы

**Ежедневно**:
- Проверка здоровья системы (health checks)
- Проверка disk space
- Ревью критических ошибок в логах
- Backup verification

**Еженедельно**:
- Тестирование backup восстановления
- Performance анализ (медленные queries)
- Security logs review

**Ежемесячно**:
- Database maintenance (VACUUM, ANALYZE)
- Cleanup old logs and temp files
- Certificate expiry review
- Dependency updates

---

### OPR-MAINT-002: Документация операций

**Обязательные документы**:
- Installation guide
- Configuration guide
- Operation runbooks
- Troubleshooting guide
- Disaster recovery procedures
- Security hardening guide

---

## 11. Требования к поддержке

### OPR-SUPPORT-001: Support уровни

- **L1 Support**: Ticket обработка, первичная диагностика
- **L2 Support**: Инженеры, debugging, patch development
- **L3 Support**: Архитекторы, design issues, custom development

---

### OPR-SUPPORT-002: Response times

| Severity | Initial Response | Resolution Target |
|----------|------------------|-------------------|
| Critical | 30 minutes | 4 hours |
| High | 2 hours | 8 hours |
| Medium | 8 hours | 24 hours |
| Low | 24 hours | 7 days |

---

## 12. Требования к обучению

### OPR-TRAIN-001: Обучение операторов

- **Initial training**: Перед первым использованием
- **Refresher training**: Ежегодно
- **New feature training**: При крупных обновлениях
- **Certification**: Опциональный экзамен

---

## 13. Метрики успеха операций

**Target metrics**:
- Uptime: 99.5%+
- MTBF: > 720 часов (30 дней)
- MTTR: < 30 минут
- RTO: < 4 часов
- RPO: < 1 часа
- Backup success rate: 100%
- Deployment success rate: 95%+

---

**Статус**: 🟢 Утверждено
**Следующий шаг**: Scalability Requirements (SR-006)
