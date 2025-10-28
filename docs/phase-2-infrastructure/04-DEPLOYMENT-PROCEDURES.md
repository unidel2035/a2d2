# Deployment Procedures

**Версия**: 1.0
**Статус**: Документировано
**Дата**: 28 октября 2025

## 📋 Содержание

1. [Deployment Strategy](#deployment-strategy)
2. [Blue-Green Deployment](#blue-green-deployment)
3. [Database Migrations](#database-migrations)
4. [Rollback Procedures](#rollback-procedures)
5. [Health Checks](#health-checks)
6. [Deployment Checklist](#deployment-checklist)

## Deployment Strategy

### CICD-004 & CICD-005: Automated Deployment

```
┌─────────────────────────────────────────────────────┐
│               Deployment Flow                       │
└─────────────────────────────────────────────────────┘

Code Push to Main
       │
       ▼
GitHub Actions CI
(Tests, Linting, Security)
       │
       ├─ All checks pass?
       │    Yes → Continue
       │    No  → Reject
       │
       ▼
Build Docker Image
Tag: :latest, :sha
       │
       ▼
Push to Registry
       │
       ├─ Staging Deployment
       │  (Automatic on main)
       │
       ├─ Staging Tests
       │  (Smoke tests, E2E)
       │
       └─ Wait for approval
              │
              ├─ Approved
              │    │
              │    ▼
              │ Blue-Green
              │ Production
              │ Deployment
              │    │
              │    ├─ Deploy to Green
              │    ├─ Run tests
              │    ├─ Traffic switch
              │    └─ Monitor
              │
              └─ Rejected
                 │
                 ▼
              Keep Staging
```

## Blue-Green Deployment

### Zero-downtime deployment strategy

#### Kamal Configuration

```yaml
# config/deploy.yml

service: a2d2
image: a2d2/app

servers:
  web:
    hosts:
      - 1.2.3.4
      - 1.2.3.5
      - 1.2.3.6
    options:
      cpus: 2
      memory: 512MB
  job:
    hosts:
      - 1.2.3.7
    options:
      cpus: 1
      memory: 256MB

registry:
  server: ghcr.io
  username: $GHCR_USERNAME
  password: $GHCR_TOKEN

env:
  RAILS_ENV: production
  RAILS_LOG_TO_STDOUT: 1

volumes:
  - "storage:/rails/storage"

healthcheck:
  path: /health
  interval: 5s
  timeout: 3s
  max_attempts: 5

# Blue-green deployment settings
boot:
  wait: 5
  limit: 30

# Production environment overrides
production:
  env:
    RAILS_ENV: production
    SOLID_QUEUE_PROCESS_ID: <%= `hostname` %>

  servers:
    web:
      hosts:
        - production-web-1.internal:22
        - production-web-2.internal:22
        - production-web-3.internal:22
      options:
        cpus: 4
        memory: 1024MB
```

#### Kamal Blue-Green Deployment

```bash
#!/bin/bash
# scripts/deploy-production.sh

set -e

ENVIRONMENT="production"
DEPLOYMENT_TYPE="${1:-blue-green}"

echo "🚀 Starting $DEPLOYMENT_TYPE deployment to $ENVIRONMENT..."

# 1. Build Docker image
echo "📦 Building Docker image..."
docker build -t a2d2:latest .

# 2. Push to registry
echo "📤 Pushing to registry..."
docker tag a2d2:latest ghcr.io/unidel2035/a2d2:latest
docker push ghcr.io/unidel2035/a2d2:latest

# 3. Pull latest configuration
echo "🔄 Pulling latest deployment configuration..."
git pull origin main

# 4. Deploy to green environment
echo "🟢 Deploying to green environment..."
kamal deploy -s $ENVIRONMENT --skip-web

# 5. Run health checks
echo "🏥 Running health checks on green environment..."
sleep 10
if ! curl -f http://green-instance:3000/health; then
  echo "❌ Green environment health check failed!"
  exit 1
fi

# 6. Run smoke tests
echo "🧪 Running smoke tests..."
./scripts/smoke-tests.sh green-instance

# 7. Switch traffic (blue-green)
echo "🔀 Switching traffic to green environment..."
kamal proxy config

# 8. Monitor
echo "📊 Monitoring deployment..."
kamal logs -s $ENVIRONMENT --follow &
MONITOR_PID=$!

sleep 30

# 9. Check metrics
echo "📈 Checking error rates..."
if grep -q "error_rate > 5%" <(kamal proxy logs); then
  echo "⚠️  High error rate detected, rolling back..."
  kill $MONITOR_PID
  ./scripts/rollback-production.sh
  exit 1
fi

echo "✅ Deployment successful!"
kill $MONITOR_PID 2>/dev/null || true
```

## Database Migrations

### Safe migration strategy

```bash
#!/bin/bash
# scripts/deploy-with-migrations.sh

set -e

echo "🔒 Starting zero-downtime deployment with migrations..."

# 1. Run migrations on primary database (before deployment)
echo "📊 Running database migrations..."
kamal exec -s production 'bin/rails db:migrate'

if [ $? -ne 0 ]; then
  echo "❌ Migration failed!"
  exit 1
fi

# 2. Verify replica is up-to-date
echo "⏳ Waiting for replica to catch up..."
sleep 30
kamal exec -s production 'bin/rails db:verify_migrations'

# 3. Deploy application code
echo "🚀 Deploying application..."
kamal deploy -s production

# 4. Run post-deployment tasks
echo "🔧 Running post-deployment tasks..."
kamal exec -s production 'bin/rails cache:clear'

# 5. Verify deployment
echo "✅ Verifying deployment..."
./scripts/verify-deployment.sh

echo "✅ Deployment completed successfully!"
```

### Rails migration best practices

```ruby
# db/migrate/20250101000001_example_migration.rb

class ExampleMigration < ActiveRecord::Migration[8.0]
  # Disable transaction for zero-downtime deploys
  # (only for specific changes that need it)
  disable_ddl_transaction!

  def up
    # Option 1: Add column with default (backwards compatible)
    # This won't block for large tables
    add_column :users, :new_field, :string, null: true, default: nil

    # Option 2: Add index concurrently
    add_index :users, :new_field, algorithm: :concurrently

    # Option 3: For complex changes, use temporary tables
    create_table :users_new do |t|
      # ... new schema
    end

    # Backfill data
    # ... copy logic

    # Swap tables
    # rename_table :users, :users_old
    # rename_table :users_new, :users
  end

  def down
    # Reverse the changes
    remove_column :users, :new_field
  end
end
```

## Rollback Procedures

### CICD-005: Rollback mechanism

#### Quick rollback

```bash
#!/bin/bash
# scripts/rollback-production.sh

DEPLOYMENT_ID="${1:-latest}"

echo "⏮️  Rolling back to previous deployment..."

# 1. Get previous deployment
PREVIOUS_VERSION=$(kamal version -s production | grep -oP "v\K\d+.\d+.\d+" | head -2 | tail -1)

if [ -z "$PREVIOUS_VERSION" ]; then
  echo "❌ No previous version found!"
  exit 1
fi

# 2. Confirm rollback
read -p "⚠️  Rollback to version $PREVIOUS_VERSION? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  exit 1
fi

# 3. Tag previous image
echo "📌 Tagging previous version..."
docker tag a2d2:$PREVIOUS_VERSION a2d2:production

# 4. Rollback deployment
echo "🔄 Rolling back..."
kamal deploy -s production

# 5. Verify
echo "🏥 Verifying rollback..."
sleep 10
if curl -f https://example.com/health; then
  echo "✅ Rollback successful!"

  # 6. Notify team
  slack_message "Rollback to $PREVIOUS_VERSION completed successfully"
else
  echo "❌ Rollback verification failed!"
  exit 1
fi
```

#### Database rollback

```bash
#!/bin/bash
# scripts/rollback-database.sh

echo "🔄 Rolling back database migrations..."

# Get current version
CURRENT_MIGRATION=$(kamal exec -s production 'bin/rails runner "puts ActiveRecord::Migrator.current_version"')

echo "Current migration version: $CURRENT_MIGRATION"

# Rollback one step
kamal exec -s production 'bin/rails db:rollback STEP=1'

# Verify
kamal exec -s production 'bin/rails db:status'

echo "✅ Database rollback completed"
```

## Health Checks

### Health check implementation

```ruby
# config/routes.rb
get '/health', to: 'health#check'
get '/health/ready', to: 'health#ready'
get '/health/live', to: 'health#live'
```

```ruby
# app/controllers/health_controller.rb
class HealthController < ApplicationController
  skip_authentication_checks

  def check
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: ENV['APP_VERSION']
    }
  end

  def ready
    checks = {
      database: database_healthy?,
      redis: redis_healthy?,
      queue: queue_healthy?
    }

    if checks.values.all?
      render json: { status: 'ready', checks: checks }
    else
      render json: { status: 'not_ready', checks: checks }, status: 503
    end
  end

  def live
    render json: { status: 'live', timestamp: Time.current.iso8601 }
  end

  private

  def database_healthy?
    ActiveRecord::Base.connection.active? && !ActiveRecord::Base.connection.reconnect!
  rescue StandardError
    false
  end

  def redis_healthy?
    Redis.new.ping == 'PONG'
  rescue StandardError
    false
  end

  def queue_healthy?
    # Check if job queue is processing
    !SolidQueue::Job.stuck.exists?
  rescue StandardError
    false
  end
end
```

### Kubernetes/Docker health probes

```yaml
# Dockerfile health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

```yaml
# Kamal health check
healthcheck:
  path: /health
  interval: 5s
  timeout: 3s
  max_attempts: 5
```

## Deployment Checklist

### Pre-deployment

- [ ] All tests passing in CI
- [ ] Code review approved
- [ ] Database migrations prepared and tested
- [ ] Dependencies updated and audited
- [ ] Configuration secrets verified
- [ ] Monitoring and alerts configured
- [ ] Team notified of deployment
- [ ] Backup taken (especially for database)
- [ ] Rollback plan documented
- [ ] Load testing results reviewed

### During deployment

- [ ] Health checks passing
- [ ] Error rate monitored (<0.5%)
- [ ] Response times monitored (<2s p95)
- [ ] Database query performance acceptable
- [ ] No unusual resource usage (CPU, Memory, Disk)
- [ ] Cache working properly
- [ ] Background jobs processing
- [ ] External API integrations working
- [ ] Logs being collected properly
- [ ] Alerts functioning

### Post-deployment

- [ ] All services healthy
- [ ] Database replication synced
- [ ] Monitoring dashboards updated
- [ ] Performance baselines established
- [ ] Error tracking showing no new errors
- [ ] Security scan completed
- [ ] User-facing features working
- [ ] Documentation updated
- [ ] Team notified of completion
- [ ] Post-mortem scheduled if issues found

### Deployment windows

**Standard deployments:**
- Tuesday - Thursday: 10:00 - 14:00 UTC
- No deployments Friday afternoon or weekends

**Emergency hotfixes:**
- Any time with on-call approval

---

**Статус**: ✓ Готово к использованию
**Дата обновления**: 28 октября 2025
