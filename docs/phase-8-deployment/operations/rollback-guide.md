# DEPLOY-004: Rollback Procedures

**Status**: Complete
**Version**: 1.0
**Last Updated**: 2025-10-28

## Overview

Comprehensive rollback procedures for the A2D2 platform to quickly revert problematic deployments.

## Rollback Decision Matrix

| Severity | Symptoms | Action | Timeframe |
|----------|----------|--------|-----------|
| **Critical** | Service down, 500 errors, data loss | Immediate rollback | < 5 minutes |
| **High** | >5% error rate, severe performance degradation | Fast rollback | < 15 minutes |
| **Medium** | <5% error rate, minor bugs | Evaluate, then rollback or hotfix | < 30 minutes |
| **Low** | UI issues, non-critical bugs | Hotfix in next deployment | Next release |

## Quick Rollback Commands

### Application Rollback

```bash
# One-command rollback
/var/www/a2d2/scripts/rollback.sh

# Or manual:
cd /var/www/a2d2
ln -nfs releases/PREVIOUS_VERSION current
sudo systemctl reload a2d2-web a2d2-worker
```

### Database Rollback

```bash
# Rollback last migration
cd /var/www/a2d2/current
RAILS_ENV=production bundle exec rails db:rollback

# Rollback specific version
RAILS_ENV=production bundle exec rails db:migrate:down VERSION=20251028120000
```

## Automated Rollback Script

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

## Rollback Scenarios

### Scenario 1: Application Code Issue

**Symptoms**: Crashes, 500 errors, exceptions

**Solution**:
```bash
# 1. Rollback application
./scripts/rollback.sh

# 2. Verify health
curl http://localhost:3000/health

# 3. Monitor logs
tail -f log/production.log
```

### Scenario 2: Database Migration Issue

**Symptoms**: Database errors, migration failures

**Solution**:
```bash
# 1. Rollback migration
cd /var/www/a2d2/current
RAILS_ENV=production bundle exec rails db:rollback

# 2. Verify database state
RAILS_ENV=production bundle exec rails db:migrate:status

# 3. Restart application
sudo systemctl restart a2d2-web a2d2-worker
```

### Scenario 3: Performance Degradation

**Symptoms**: Slow response times, high CPU/memory

**Solution**:
```bash
# 1. Capture metrics
./scripts/capture-diagnostics.sh

# 2. Rollback if severe
./scripts/rollback.sh

# 3. Analyze later
less /var/log/a2d2/diagnostics-*.log
```

### Scenario 4: Data Corruption

**Symptoms**: Invalid data, missing records

**Solution**:
```bash
# 1. STOP ALL SERVICES IMMEDIATELY
sudo systemctl stop a2d2-web a2d2-worker

# 2. Restore database from backup
./scripts/restore-from-backup.sh /var/backups/postgresql/latest.dump

# 3. Rollback application
./scripts/rollback.sh

# 4. Investigate root cause
# DO NOT re-deploy until issue identified
```

## Database Restore Procedures

### Full Database Restore

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

### Point-in-Time Recovery (PITR)

```bash
# Restore to specific timestamp
pg_restore_pitr --target-time="2025-10-28 14:30:00" \
    --backup-dir=/var/backups/postgresql/base \
    --wal-dir=/var/backups/postgresql/wal
```

## Monitoring During Rollback

```bash
# Terminal 1: Application logs
tail -f /var/www/a2d2/shared/log/production.log

# Terminal 2: System logs
journalctl -u a2d2-web -u a2d2-worker -f

# Terminal 3: Nginx logs
tail -f /var/log/nginx/error.log

# Terminal 4: Database activity
watch -n 1 'sudo -u postgres psql -c "SELECT count(*) FROM pg_stat_activity;"'
```

## Post-Rollback Actions

1. **Incident Report**: Document what happened
2. **Root Cause Analysis**: Identify why deployment failed
3. **Fix**: Prepare proper fix
4. **Test**: Thoroughly test fix in staging
5. **Re-deploy**: When ready, deploy with caution

## Rollback Testing

### Regular Drills

```bash
# Monthly rollback drill script
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

Run monthly:

```bash
# Add to crontab
0 3 1 * * /var/www/a2d2/scripts/test-rollback.sh > /var/log/a2d2/rollback-drill.log 2>&1
```

## Emergency Contact Procedures

If rollback doesn't resolve the issue:

1. **Escalate** to senior engineers
2. **Contact** infrastructure team
3. **Enable** maintenance mode
4. **Communicate** with stakeholders

```bash
# Enable maintenance mode
sudo systemctl stop a2d2-web
sudo cp /var/www/a2d2/public/maintenance.html /var/www/a2d2/public/index.html
```

---

**Document Version**: 1.0
**Last Updated**: 2025-10-28
**Maintainer**: A2D2 DevOps Team
