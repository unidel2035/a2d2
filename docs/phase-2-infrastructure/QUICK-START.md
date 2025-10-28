# Phase 2: Quick Start Guide

**Get started with A2D2 infrastructure in minutes!**

## 🚀 Local Development Setup (5 minutes)

### Prerequisites
- Docker and Docker Compose installed
- Git
- Ruby 3.3.6 (optional, for local development)

### Start the stack

```bash
# Clone repository
git clone https://github.com/unidel2035/a2d2.git
cd a2d2

# Create .env file
cp .env.example .env

# Start all services
docker-compose up -d

# Initialize database
docker-compose exec app bin/rails db:create db:migrate db:seed

# Verify services
docker-compose ps
```

### Access the application

| Service | URL | Credentials |
|---------|-----|-------------|
| **Web App** | http://localhost:3000 | - |
| **Grafana** | http://localhost:3001 | admin / admin |
| **Prometheus** | http://localhost:9090 | - |
| **Loki** | http://localhost:3100 | - |
| **PostgreSQL** | localhost:5432 | a2d2_user / development_password |
| **Redis** | localhost:6379 | - (use development_password) |

### View logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f app
docker-compose logs -f postgres
docker-compose logs -f redis

# Filter logs
docker-compose logs --tail=100 app | grep error
```

### Stop services

```bash
# Stop all (keep data)
docker-compose stop

# Remove all (delete data)
docker-compose down

# Remove all including volumes
docker-compose down -v
```

## 📊 Dashboard Setup (10 minutes)

### Access Grafana

1. Open http://localhost:3001
2. Login: admin / admin
3. Add Prometheus data source:
   - URL: http://prometheus:9090
   - Click "Save & test"
4. Add Loki data source:
   - URL: http://loki:3100
   - Click "Save & test"

### View Metrics

- **Prometheus**: http://localhost:9090
  - Query: `rate(rails_http_requests_total[5m])`
  - Query: `histogram_quantile(0.95, rate(rails_http_request_duration_seconds_bucket[5m]))`

### View Logs

- **Loki**: http://localhost:3100/graph
  - Query: `{job="rails"}`

## 🧪 Testing

### Run tests locally

```bash
# All tests
docker-compose exec app bin/rails test

# Unit tests only
docker-compose exec app bin/rails test:unit

# Integration tests
docker-compose exec app bin/rails test:integration

# System tests
docker-compose exec app bin/rails test:system

# With coverage
docker-compose exec app bundle exec simplecov
```

### Run security scans

```bash
# Brakeman
docker-compose exec app bundle exec brakeman --no-pager

# bundler-audit
docker-compose exec app bundle exec bundler-audit

# RuboCop
docker-compose exec app bundle exec rubocop
```

## 🔄 Database Operations

### Create backup

```bash
docker-compose exec postgres pg_dump \
  -U a2d2_user -d a2d2_development \
  > backup.sql
```

### Restore backup

```bash
docker-compose exec -T postgres psql \
  -U a2d2_user -d a2d2_development \
  < backup.sql
```

### Reset database

```bash
docker-compose exec app bin/rails db:drop db:create db:migrate db:seed
```

### Access PostgreSQL directly

```bash
docker-compose exec postgres psql \
  -U a2d2_user -d a2d2_development
```

### Connect to Redis

```bash
docker-compose exec redis redis-cli
```

## 🚀 Staging Deployment

### Prerequisites

```bash
# Install Kamal
gem install kamal

# Set environment variables
export GHCR_USERNAME=your-github-username
export GHCR_TOKEN=your-github-token
export RAILS_MASTER_KEY=$(cat config/master.key)
```

### Deploy to staging

```bash
# Deploy
kamal deploy -s staging

# Monitor deployment
kamal logs -s staging --follow

# Check status
kamal apps -s staging

# SSH into server
kamal exec -s staging 'whoami'

# Run commands
kamal exec -s staging 'bin/rails db:migrate'

# Restart services
kamal restart -s staging
```

### Monitoring

```bash
# View logs
kamal logs -s staging --follow

# Check health
curl https://staging.example.com/health

# View metrics
curl http://staging-web-1.internal:3000/metrics | grep rails
```

## 🌍 Production Deployment

### Prerequisites

```bash
# Ensure all staging tests pass
kamal logs -s staging --grep "error"

# Create database backup
kamal exec -s production 'bin/rails db:backup'
```

### Blue-green deployment

```bash
# Step 1: Deploy to green environment
kamal deploy -s production --skip-web

# Step 2: Run health checks
sleep 10
curl -f http://green-instance:3000/health

# Step 3: Run tests
./scripts/smoke-tests.sh green-instance

# Step 4: Switch traffic
kamal proxy config

# Step 5: Monitor
kamal logs -s production --follow

# Step 6: Verify metrics
curl http://production-web-1.internal:3000/metrics
```

### Rollback if issues

```bash
# Option 1: Quick rollback
./scripts/rollback-production.sh

# Option 2: Rollback to specific version
./scripts/rollback-production.sh v1.2.3

# Option 3: Rollback database
./scripts/rollback-database.sh
```

## 🔐 Secrets Management

### GitHub Actions Secrets

Set these in repository settings → Secrets and variables → Actions:

```bash
GHCR_USERNAME=your-github-username
GHCR_TOKEN=github_pat_...
RAILS_MASTER_KEY=<from config/master.key>
SLACK_WEBHOOK=https://hooks.slack.com/...
DATABASE_URL=postgresql://user:pass@host/db
REDIS_URL=redis://:password@host:6379
```

### Local development

```bash
# Create .env file
cat > .env <<EOF
RAILS_ENV=development
DATABASE_URL=postgresql://a2d2_user:development_password@localhost:5432/a2d2_development
REDIS_URL=redis://:development_password@localhost:6379
EOF

# Load environment
source .env
```

## 📋 Health Checks

### Application health

```bash
# Liveness check
curl http://localhost:3000/health/live

# Readiness check (dependencies)
curl http://localhost:3000/health/ready

# Full health
curl http://localhost:3000/health
```

### Database health

```bash
# Check connection
docker-compose exec postgres pg_isready -U a2d2_user

# Check replication
docker-compose exec postgres psql -U a2d2_user -c "SELECT * FROM pg_stat_replication;"
```

### Redis health

```bash
# Check connection
docker-compose exec redis redis-cli ping

# Check memory
docker-compose exec redis redis-cli info memory
```

## 📊 Monitoring

### Key metrics to watch

**Application**:
- Request rate: `rate(rails_http_requests_total[5m])`
- Error rate: `rate(rails_http_requests_total{status=~"5.."}[5m])`
- Response time: `histogram_quantile(0.95, rate(rails_http_request_duration_seconds_bucket[5m]))`

**Database**:
- Active connections: `pg_stat_activity_count`
- Query time: `rate(pg_stat_statements_total_time[5m])`
- Cache hits: `rate(pg_stat_user_tables_idx_scan[5m])`

**Infrastructure**:
- CPU: `rate(node_cpu_seconds_total[5m])`
- Memory: `node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes`
- Disk: `node_filesystem_avail_bytes / node_filesystem_size_bytes`

## 🆘 Troubleshooting

### Services won't start

```bash
# Check logs
docker-compose logs app
docker-compose logs postgres

# Check port conflicts
lsof -i :3000
lsof -i :5432

# Rebuild images
docker-compose build --no-cache
```

### Database connection fails

```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check credentials in .env
grep DATABASE_URL .env

# Test connection
docker-compose exec postgres psql -U a2d2_user -c "SELECT 1"
```

### High memory usage

```bash
# Check which container uses memory
docker stats

# Clear Rails cache
docker-compose exec app bin/rails cache:clear

# Clean Docker system
docker system prune
```

### Deployment fails

```bash
# Check deployment logs
kamal logs -s staging

# Check Git status
git status
git log --oneline -5

# Verify configuration
cat config/deploy.yml

# Test Kamal setup
kamal audit
```

## 📚 Further Reading

- [Production Environment Guide](./01-PRODUCTION-ENVIRONMENT.md)
- [CI/CD Pipeline Documentation](./02-CI-CD-PIPELINE.md)
- [Monitoring & Logging Setup](./03-MONITORING-LOGGING.md)
- [Deployment Procedures](./04-DEPLOYMENT-PROCEDURES.md)
- [Security Hardening](./05-INFRASTRUCTURE-SECURITY.md)
- [Backup & Recovery](./06-DISASTER-RECOVERY.md)

## 💡 Tips

### Speed up local development

```bash
# Skip unused services
docker-compose up -d app postgres redis

# Or use specific service
docker-compose up -d app
```

### Restart after code changes

```bash
# Rails server auto-reloads on file changes
# No restart needed for most changes

# For Gemfile changes
docker-compose up app
```

### Clean up periodically

```bash
# Remove old images
docker image prune

# Remove stopped containers
docker container prune

# Remove unused volumes
docker volume prune
```

## ✅ Checklist

### Before committing code

- [ ] Tests pass: `bin/rails test`
- [ ] No linting issues: `bundle exec rubocop`
- [ ] No security issues: `bundle exec brakeman`
- [ ] Dependencies are safe: `bundle exec bundler-audit`

### Before pushing to staging

- [ ] All tests pass in CI
- [ ] Code review approved
- [ ] Database migrations are safe
- [ ] Environment variables configured

### Before pushing to production

- [ ] Staging tests all pass
- [ ] Performance metrics baseline established
- [ ] Backup created
- [ ] Team notified
- [ ] Rollback plan documented

---

**Last Updated**: 28 October 2025
**Status**: ✅ Ready to Use
