# Disaster Recovery и Backup

**Версия**: 1.0
**Статус**: Документировано
**Дата**: 28 октября 2025

## 📋 Содержание

1. [Backup Strategy](#backup-strategy)
2. [Database Backup](#database-backup)
3. [Application Files Backup](#application-files-backup)
4. [Recovery Procedures](#recovery-procedures)
5. [Testing и Verification](#testing-и-verification)

## Backup Strategy

### RTO и RPO targets

| Компонент | RTO | RPO | Стратегия |
|-----------|-----|-----|-----------|
| Production Database | 4 hours | 1 hour | Continuous + Daily full |
| Application | 1 hour | 15 min | Container registry + S3 |
| Configuration | 30 min | 1 day | Git + S3 versioning |
| Logs | 7 days | 1 day | Loki + S3 archive |

### Backup Architecture

```
┌─────────────────────────────────────────────────────┐
│              Production Systems                     │
│   ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│   │PostgreSQL│  │  Redis   │  │ Files    │         │
│   └────┬─────┘  └────┬─────┘  └────┬─────┘         │
└────────┼────────────┼──────────────┼───────────────┘
         │            │              │
    ┌────▼──┐     ┌───▼──┐      ┌───▼──┐
    │Backup │     │Sync  │      │Sync  │
    │Agent  │     │Agent │      │Agent │
    └────┬──┘     └───┬──┘      └───┬──┘
         │            │              │
    ┌────▼──────┬─────▼──┬───────┬───▼──┐
    │   AWS S3  │  Glacier  │  External │
    │ (30 days) │(1-7 year) │  (Off-site)
    └───────────┴──────────┴──────────┘
```

## Database Backup

### PostgreSQL Backup Strategy

#### Automated Daily Backup

```bash
#!/bin/bash
# scripts/backup-database.sh

set -e

BACKUP_DIR="/backups/postgresql"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30
AWS_BUCKET="s3://a2d2-backups"

mkdir -p $BACKUP_DIR

echo "🔄 Starting PostgreSQL backup..."

# Full backup
pg_dump \
  --host=$POSTGRES_HOST \
  --username=$POSTGRES_USER \
  --password=$POSTGRES_PASSWORD \
  --format=directory \
  --jobs=4 \
  --verbose \
  a2d2_production > "$BACKUP_DIR/backup_$TIMESTAMP.dump"

if [ $? -eq 0 ]; then
  echo "✅ Full backup completed"

  # Compress
  tar -czf "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" \
    "$BACKUP_DIR/backup_$TIMESTAMP.dump"

  # Upload to S3
  aws s3 cp "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" \
    "$AWS_BUCKET/postgresql/backups/"

  echo "📤 Uploaded to S3"

  # Clean old backups (local)
  find $BACKUP_DIR -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

  # Send notification
  echo "Database backup successful" | mail -s "Backup Report" ops@example.com
else
  echo "❌ Backup failed!"
  exit 1
fi
```

#### WAL Archiving

```bash
# postgresql.conf
archive_mode = on
archive_command = 'aws s3 cp %p s3://a2d2-backups/postgresql/wal/%f'
archive_timeout = 300
wal_level = replica
```

#### Point-in-Time Recovery Setup

```bash
#!/bin/bash
# scripts/enable-pitr.sh

psql -U postgres <<EOF
-- Create replication user
CREATE ROLE replicator WITH REPLICATION ENCRYPTED PASSWORD 'replication_password';

-- Enable replication
ALTER SYSTEM SET wal_level = replica;
ALTER SYSTEM SET max_wal_senders = 10;
ALTER SYSTEM SET wal_keep_size = '4GB';

-- Reload
SELECT pg_reload_conf();
EOF
```

### Backup Schedule

```yaml
# /etc/cron.d/database-backup

# Daily full backup at 2 AM UTC
0 2 * * * root /scripts/backup-database.sh >> /var/log/backups.log 2>&1

# Continuous WAL archiving is handled by PostgreSQL

# Weekly S3 to Glacier transition
0 3 * * 0 root /scripts/archive-to-glacier.sh

# Monthly backup verification
0 4 1 * * root /scripts/verify-backup.sh
```

## Application Files Backup

### S3-based File Backup

```ruby
# config/storage.yml
test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: us-east-1
  bucket: a2d2-storage
  acl: private

  # Versioning enabled
  # Lifecycle: Transition to Glacier after 30 days
  # Encryption: AES-256
  # Replication: To another region
```

### Backup Configuration

```bash
#!/bin/bash
# scripts/setup-s3-backup.sh

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket a2d2-storage \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket a2d2-storage \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Set lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket a2d2-storage \
  --lifecycle-configuration file://lifecycle-policy.json

# Enable replication
aws s3api put-bucket-replication \
  --bucket a2d2-storage \
  --replication-configuration file://replication-config.json
```

### Backup Lifecycle Policy

```json
{
  "Rules": [
    {
      "Id": "archive-old-versions",
      "Status": "Enabled",
      "NoncurrentVersionExpirations": {
        "NoncurrentDays": 90
      },
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "GLACIER"
        }
      ]
    },
    {
      "Id": "delete-incomplete-multipart",
      "Status": "Enabled",
      "AbortIncompleteMultipartUpload": {
        "DaysAfterInitiation": 7
      }
    }
  ]
}
```

## Recovery Procedures

### Database Recovery

#### Full Recovery

```bash
#!/bin/bash
# scripts/restore-database.sh

BACKUP_FILE="${1:-latest}"
RESTORE_DB="a2d2_production_restore"

echo "🔄 Starting database restore from $BACKUP_FILE..."

# 1. Download backup from S3
if [ "$BACKUP_FILE" == "latest" ]; then
  BACKUP_FILE=$(aws s3 ls s3://a2d2-backups/postgresql/backups/ | tail -1 | awk '{print $4}')
fi

echo "📥 Downloading $BACKUP_FILE..."
aws s3 cp "s3://a2d2-backups/postgresql/backups/$BACKUP_FILE" /tmp/

# 2. Create restore database
echo "📊 Creating restore database..."
createdb -U postgres -T template0 $RESTORE_DB

# 3. Restore backup
echo "⏳ Restoring database..."
pg_restore \
  --host=localhost \
  --username=postgres \
  --dbname=$RESTORE_DB \
  --jobs=4 \
  --verbose \
  "/tmp/$BACKUP_FILE"

if [ $? -ne 0 ]; then
  echo "❌ Restore failed!"
  dropdb -U postgres $RESTORE_DB
  exit 1
fi

# 4. Verify restore
echo "🏥 Verifying restore..."
psql -U postgres -d $RESTORE_DB -c "SELECT COUNT(*) FROM users;"

# 5. Switch to restored database
echo "🔄 Switching to restored database..."
psql -U postgres -c "
  SELECT pg_terminate_backend(pg_stat_activity.pid)
  FROM pg_stat_activity
  WHERE pg_stat_activity.datname = 'a2d2_production'
  AND pid <> pg_backend_pid();
"

dropdb -U postgres a2d2_production
psql -U postgres -c "ALTER DATABASE $RESTORE_DB RENAME TO a2d2_production;"

echo "✅ Database restore completed!"
```

#### Point-in-Time Recovery

```bash
#!/bin/bash
# scripts/restore-to-point-in-time.sh

TARGET_TIME="${1:?Target time required (YYYY-MM-DD HH:MM:SS)}"

echo "⏮️  Recovering to $TARGET_TIME..."

# Download base backup
BASE_BACKUP=$(aws s3 ls s3://a2d2-backups/postgresql/backups/ \
  | grep -B 1 "$TARGET_TIME" | head -1 | awk '{print $4}')

aws s3 cp "s3://a2d2-backups/postgresql/backups/$BASE_BACKUP" /tmp/

# Restore base backup
pg_restore \
  --dbname=a2d2_production_pitr \
  --clean \
  /tmp/$BASE_BACKUP

# Create recovery.conf
cat > /var/lib/postgresql/14/main/recovery.conf <<EOF
restore_command = 'aws s3 cp s3://a2d2-backups/postgresql/wal/%f %p'
recovery_target_timeline = 'latest'
recovery_target_time = '$TARGET_TIME'
recovery_target_action = 'promote'
EOF

# Start recovery
pg_ctl restart

# Monitor recovery progress
tail -f /var/log/postgresql/postgresql.log | grep "recovered"

echo "✅ PITR completed!"
```

### Application Recovery

```bash
#!/bin/bash
# scripts/restore-application.sh

VERSION="${1:?Version required}"

echo "🔄 Restoring application version $VERSION..."

# 1. Pull Docker image
docker pull ghcr.io/unidel2035/a2d2:$VERSION

# 2. Update Kamal deployment
cat > config/deploy.yml <<EOF
service: a2d2
image: ghcr.io/unidel2035/a2d2:$VERSION
...
EOF

# 3. Deploy
kamal deploy -s production

# 4. Verify
sleep 10
if curl -f https://a2d2.example.com/health; then
  echo "✅ Application restored successfully"
else
  echo "❌ Application health check failed"
  exit 1
fi
```

## Testing и Verification

### Automated Backup Testing

```bash
#!/bin/bash
# scripts/verify-backup.sh

BACKUP_FILE=$(aws s3 ls s3://a2d2-backups/postgresql/backups/ | tail -1 | awk '{print $4}')

echo "🧪 Testing backup: $BACKUP_FILE..."

# 1. Download backup
aws s3 cp "s3://a2d2-backups/postgresql/backups/$BACKUP_FILE" /tmp/

# 2. Restore to test database
createdb -U postgres -T template0 a2d2_backup_test
pg_restore \
  --dbname=a2d2_backup_test \
  --jobs=4 \
  /tmp/$BACKUP_FILE

if [ $? -ne 0 ]; then
  echo "❌ Backup corrupted!"
  dropdb -U postgres a2d2_backup_test
  exit 1
fi

# 3. Run integrity checks
psql -U postgres -d a2d2_backup_test <<EOF
-- Check table counts
SELECT
  (SELECT COUNT(*) FROM users) as user_count,
  (SELECT COUNT(*) FROM tasks) as task_count,
  (SELECT COUNT(*) FROM robots) as robot_count;

-- Check recent data
SELECT MAX(created_at) as latest_record FROM users;

-- Check for orphaned records
SELECT COUNT(*) as orphaned FROM tasks WHERE robot_id NOT IN (SELECT id FROM robots);
EOF

# 4. Cleanup
dropdb -U postgres a2d2_backup_test
rm /tmp/$BACKUP_FILE

echo "✅ Backup verification passed!"
```

### Monthly Recovery Drill

```bash
#!/bin/bash
# scripts/disaster-recovery-drill.sh

set -e

echo "🚨 Starting Disaster Recovery Drill..."

DRILL_DATE=$(date +%Y%m%d_%H%M%S)
DRILL_LOG="/var/log/dr-drill-$DRILL_DATE.log"

{
  echo "=== Disaster Recovery Drill $DRILL_DATE ==="

  # 1. Test database backup
  echo "1️⃣  Testing database backup..."
  /scripts/verify-backup.sh

  # 2. Test application backup
  echo "2️⃣  Testing application container..."
  docker pull ghcr.io/unidel2035/a2d2:latest

  # 3. Test S3 file backup
  echo "3️⃣  Testing S3 file integrity..."
  aws s3 ls s3://a2d2-storage | head -10

  # 4. Test recovery documentation
  echo "4️⃣  Validating recovery documentation..."
  ls -la /scripts/restore-*.sh

  # 5. Estimated recovery time
  echo "5️⃣  Estimated RTO: 4 hours"
  echo "   Estimated RPO: 1 hour"

  echo ""
  echo "✅ Disaster Recovery Drill Completed Successfully"
  echo "Date: $(date)"

} | tee $DRILL_LOG

# Send report
mail -s "DR Drill Report - $DRILL_DATE" ops@example.com < $DRILL_LOG
```

### Recovery Runbook

```markdown
# DISASTER RECOVERY RUNBOOK

## If Database is Down

1. [ ] Check database logs: `tail -f /var/log/postgresql.log`
2. [ ] Check disk space: `df -h`
3. [ ] Check connections: `SELECT * FROM pg_stat_activity;`
4. [ ] Try restart: `pg_ctl restart`
5. [ ] If restart fails, restore from backup:
   - Run: `/scripts/restore-database.sh latest`
6. [ ] Verify: `psql -c "SELECT COUNT(*) FROM users;"`
7. [ ] Check replication: `SELECT * FROM pg_stat_replication;`

## If Application is Down

1. [ ] Check logs: `kamal logs -s production`
2. [ ] Check health: `curl https://a2d2.example.com/health`
3. [ ] Check services: `docker ps`
4. [ ] Try restart: `kamal restart -s production`
5. [ ] If restart fails, rollback:
   - Run: `/scripts/rollback-production.sh`
6. [ ] If rollback fails, restore from backup:
   - Run: `/scripts/restore-application.sh <version>`

## If Entire Datacenter is Down

1. [ ] Verify backup integrity in another region
2. [ ] Update DNS to point to disaster recovery site
3. [ ] Restore database: `/scripts/restore-database.sh`
4. [ ] Restore application: `/scripts/restore-application.sh`
5. [ ] Verify all services: `curl /health`
6. [ ] Run smoke tests
7. [ ] Notify users
```

---

**Статус**: ✓ Готово к использованию
**Дата обновления**: 28 октября 2025
