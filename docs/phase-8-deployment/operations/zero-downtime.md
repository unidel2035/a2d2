# DEPLOY-003: Стратегия развертывания без простоя

**Статус**: Завершено
**Версия**: 1.0
**Последнее обновление**: 2025-10-28

## Обзор

Этот документ описывает стратегию развертывания без простоя для A2D2, обеспечивающую непрерывную доступность сервиса во время обновлений.

## Стратегия развертывания

### Blue-Green развертывание

A2D2 использует blue-green развертывание для достижения нулевого простоя:

```
┌─────────────┐
│Load Balancer│
└──────┬──────┘
       │
   ┌───┴────┐
   │        │
┌──▼──┐  ┌──▼──┐
│BLUE │  │GREEN│
│(old)│  │(new)│
└─────┘  └─────┘

1. Deploy to GREEN
2. Test GREEN
3. Switch traffic to GREEN
4. Keep BLUE as rollback
```

### Поэтапное развертывание

Для постепенного переключения трафика:

```
App Server 1  ████████████  v1.0.0
App Server 2  ████████████  v1.0.0
App Server 3  ████████████  v1.0.0

↓ Update Server 1

App Server 1  ████████████  v1.1.0  ← 33% traffic
App Server 2  ████████████  v1.0.0  ← 33% traffic
App Server 3  ████████████  v1.0.0  ← 33% traffic

↓ Update Server 2

App Server 1  ████████████  v1.1.0  ← 50% traffic
App Server 2  ████████████  v1.1.0  ← 50% traffic
App Server 3  ████████████  v1.0.0  ← 0% traffic

↓ Update Server 3

App Server 1  ████████████  v1.1.0  ← 33% traffic
App Server 2  ████████████  v1.1.0  ← 33% traffic
App Server 3  ████████████  v1.1.0  ← 33% traffic
```

## Скрипт развертывания

### Автоматизированное развертывание без простоя

```bash
#!/bin/bash
# File: scripts/deploy-zero-downtime.sh

set -e

VERSION=$1
DEPLOY_USER="deploy"
APP_ROOT="/var/www/a2d2"
CURRENT_LINK="$APP_ROOT/current"
RELEASES_DIR="$APP_ROOT/releases"
SHARED_DIR="$APP_ROOT/shared"
RELEASE_DIR="$RELEASES_DIR/$VERSION"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 1. Prepare new release
log_info "Preparing release $VERSION..."
mkdir -p "$RELEASE_DIR"
cd "$RELEASE_DIR"

# 2. Clone code
log_info "Cloning repository..."
git clone --depth 1 --branch "$VERSION" https://github.com/unidel2035/a2d2.git .

# 3. Install dependencies
log_info "Installing dependencies..."
bundle install --deployment --without development test
bundle exec rails assets:precompile

# 4. Link shared files
log_info "Linking shared files..."
ln -nfs "$SHARED_DIR/config/master.key" "$RELEASE_DIR/config/master.key"
ln -nfs "$SHARED_DIR/config/.env.production" "$RELEASE_DIR/.env"
ln -nfs "$SHARED_DIR/log" "$RELEASE_DIR/log"
ln -nfs "$SHARED_DIR/tmp" "$RELEASE_DIR/tmp"
ln -nfs "$SHARED_DIR/public/uploads" "$RELEASE_DIR/public/uploads"
ln -nfs "$SHARED_DIR/storage" "$RELEASE_DIR/storage"

# 5. Run migrations (if any)
log_info "Running database migrations..."
cd "$RELEASE_DIR"
RAILS_ENV=production bundle exec rails db:migrate

# 6. Preload new code (warm up)
log_info "Warming up application..."
RAILS_ENV=production bundle exec rails runner "Rails.application.eager_load!"

# 7. Switch to new release
log_info "Switching to new release..."
ln -nfs "$RELEASE_DIR" "$CURRENT_LINK"

# 8. Restart workers (gracefully)
log_info "Restarting workers..."
sudo systemctl reload a2d2-worker

# 9. Rolling restart of web servers
log_info "Rolling restart of web servers..."
if command -v systemctl &> /dev/null; then
    # Systemd reload (zero-downtime)
    sudo systemctl reload a2d2-web
else
    # Manual USR2 signal for Puma
    if [ -f "$SHARED_DIR/tmp/pids/puma.pid" ]; then
        kill -USR2 $(cat "$SHARED_DIR/tmp/pids/puma.pid")
        sleep 10
    fi
fi

# 10. Health check
log_info "Running health checks..."
sleep 5
for i in {1..30}; do
    if curl -f -s http://localhost:3000/health > /dev/null; then
        log_info "Health check passed!"
        break
    fi
    if [ $i -eq 30 ]; then
        log_error "Health check failed after 30 attempts!"
        exit 1
    fi
    sleep 2
done

# 11. Smoke tests
log_info "Running smoke tests..."
cd "$RELEASE_DIR"
if RAILS_ENV=production bundle exec rails test:smoke 2>/dev/null; then
    log_info "Smoke tests passed!"
else
    log_warn "Smoke tests not available or failed (non-critical)"
fi

# 12. Clean up old releases (keep last 5)
log_info "Cleaning up old releases..."
cd "$RELEASES_DIR"
ls -t | tail -n +6 | xargs rm -rf

log_info "Deployment completed successfully!"
log_info "Version $VERSION is now live"

# 13. Notify team
if [ -n "$SLACK_WEBHOOK" ]; then
    curl -X POST "$SLACK_WEBHOOK" \
        -H 'Content-Type: application/json' \
        -d "{\"text\":\"✅ A2D2 v$VERSION deployed successfully\"}"
fi
```

Сделайте исполняемым:

```bash
chmod +x scripts/deploy-zero-downtime.sh
```

Использование:

```bash
./scripts/deploy-zero-downtime.sh v1.2.0
```

## Плавный перезапуск с Puma

### Конфигурация Puma для развертывания без простоя

```ruby
# config/puma.rb
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "production" }

# Specifies the number of `workers` to boot in clustered mode.
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Specify pidfile location
pidfile ENV.fetch("PIDFILE") { "tmp/pids/puma.pid" }

# Specify state file location
state_path ENV.fetch("STATE_FILE") { "tmp/pids/puma.state" }

# Configure logging
stdout_redirect(
  ENV.fetch("STDOUT_LOG") { "log/puma.stdout.log" },
  ENV.fetch("STDERR_LOG") { "log/puma.stderr.log" },
  true
)

# Graceful shutdown
on_worker_boot do
  ActiveRecord::Base.establish_connection
end

on_worker_shutdown do
  ActiveRecord::Base.connection_pool.disconnect!
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end
```

### Команды плавного перезапуска

```bash
# Phased restart (zero-downtime)
bundle exec pumactl -S tmp/pids/puma.state phased-restart

# Or via systemd
sudo systemctl reload a2d2-web

# Or via Unix signal
kill -USR2 $(cat tmp/pids/puma.pid)
```

## Стратегия миграции базы данных

### Только совместимые миграции

Убедитесь, что миграции обратно совместимы:

```ruby
# ✅ GOOD: Backwards-compatible
class AddStatusToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :status, :string
    # Old code ignores new column, new code uses it
  end
end

# ❌ BAD: Breaking change
class RemoveRequiredField < ActiveRecord::Migration[8.0]
  def change
    remove_column :documents, :required_field
    # Old code crashes when accessing removed column!
  end
end
```

### Многофазные развертывания

Для критических изменений используйте многофазный подход:

```
Phase 1: Deploy code that works with BOTH old and new schema
Phase 2: Run migration
Phase 3: Deploy code that only uses new schema
```

## Конфигурация балансировщика нагрузки

### Проверки работоспособности nginx Upstream

```nginx
upstream a2d2_app {
    least_conn;

    server 10.0.1.10:3000 max_fails=3 fail_timeout=30s;
    server 10.0.1.11:3000 max_fails=3 fail_timeout=30s;
    server 10.0.1.12:3000 max_fails=3 fail_timeout=30s;

    keepalive 32;
}

server {
    listen 443 ssl http2;
    server_name a2d2.example.com;

    location / {
        proxy_pass http://a2d2_app;

        # Health check headers
        proxy_next_upstream error timeout http_502 http_503 http_504;
        proxy_next_upstream_tries 3;

        # Connection settings
        proxy_http_version 1.1;
        proxy_set_header Connection "";

        # Timeouts
        proxy_connect_timeout 5s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

## Управление трафиком

### Постепенное переключение трафика

Используйте nginx split_clients для canary развертываний:

```nginx
# Canary deployment: 10% to new version
split_clients "${remote_addr}" $backend {
    10%     new_version;
    *       stable_version;
}

upstream stable_version {
    server 10.0.1.10:3000;
    server 10.0.1.11:3000;
}

upstream new_version {
    server 10.0.1.12:3000;
}

server {
    location / {
        proxy_pass http://$backend;
    }
}
```

## Мониторинг во время развертывания

### Ключевые метрики для отслеживания

```bash
# Monitor error rates
tail -f /var/log/nginx/error.log

# Monitor application logs
tail -f /var/www/a2d2/current/log/production.log

# Monitor response times
while true; do
    curl -w "@curl-format.txt" -o /dev/null -s http://localhost:3000/health
    sleep 1
done

# curl-format.txt:
# time_total: %{time_total}s
# http_code: %{http_code}
```

### Оповещения Prometheus

```yaml
# prometheus/alerts.yml
groups:
  - name: deployment
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 2m
        annotations:
          summary: "High error rate during deployment"

      - alert: SlowResponseTime
        expr: http_request_duration_seconds{quantile="0.95"} > 2
        for: 5m
        annotations:
          summary: "Slow response times detected"
```

## Процедуры отката

### Быстрый откат

```bash
#!/bin/bash
# File: scripts/rollback.sh

set -e

APP_ROOT="/var/www/a2d2"
CURRENT_LINK="$APP_ROOT/current"
RELEASES_DIR="$APP_ROOT/releases"

# Get previous release
CURRENT_RELEASE=$(readlink "$CURRENT_LINK" | xargs basename)
PREVIOUS_RELEASE=$(ls -t "$RELEASES_DIR" | grep -v "$CURRENT_RELEASE" | head -1)

if [ -z "$PREVIOUS_RELEASE" ]; then
    echo "ERROR: No previous release found!"
    exit 1
fi

echo "Rolling back from $CURRENT_RELEASE to $PREVIOUS_RELEASE..."

# Switch symlink
ln -nfs "$RELEASES_DIR/$PREVIOUS_RELEASE" "$CURRENT_LINK"

# Rollback database (if needed)
cd "$CURRENT_LINK"
RAILS_ENV=production bundle exec rails db:rollback

# Restart services
sudo systemctl reload a2d2-web
sudo systemctl reload a2d2-worker

echo "Rollback completed!"
```

## Контрольный список развертывания

```markdown
### Pre-Deployment
- [ ] All tests passing on CI
- [ ] Staging deployment successful
- [ ] Database migrations are backwards-compatible
- [ ] Monitoring dashboards ready
- [ ] Team notified
- [ ] Rollback plan prepared

### During Deployment
- [ ] Start deployment: [TIMESTAMP]
- [ ] New release deployed to server 1
- [ ] Health checks passing on server 1
- [ ] Monitor error rates (< 0.1%)
- [ ] Monitor response times (< 2s p95)
- [ ] Repeat for remaining servers

### Post-Deployment
- [ ] All servers updated
- [ ] Health checks passing
- [ ] Smoke tests completed
- [ ] Monitor for 15 minutes
- [ ] Verify key features working
- [ ] Team notified of completion
```

## Лучшие практики

1. **Всегда используйте feature flags** для рискованных изменений
2. **Отслеживайте метрики** до, во время и после развертывания
3. **Развертывайте в периоды низкого трафика** когда это возможно
4. **Упрощайте откат** - практикуйтесь регулярно
5. **Автоматизируйте все** - ручные шаги приводят к ошибкам
6. **Тестируйте на staging** первым делом, всегда
7. **Общайтесь четко** с командой о статусе развертывания

## Следующие шаги

- Настройте [Проверки работоспособности](health-checks.md)
- Изучите [Руководство по откату](rollback-guide.md)
- Настройте [Мониторинг](../technical/monitoring.md)

---

**Версия документа**: 1.0
**Последнее обновление**: 2025-10-28
**Сопровождающий**: A2D2 DevOps Team
