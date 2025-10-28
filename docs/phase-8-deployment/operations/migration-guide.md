# DEPLOY-002: Database Migration Guide

**Status**: Complete
**Version**: 1.0
**Last Updated**: 2025-10-28

## Overview

This document provides comprehensive procedures for database migrations in the A2D2 platform, covering both initial setup and ongoing schema changes.

## Pre-Migration Checklist

Before running any migration:

- [ ] **Backup**: Create a full database backup
- [ ] **Review**: Examine migration files for potential issues
- [ ] **Test**: Run migration on staging environment first
- [ ] **Downtime**: Schedule maintenance window if needed
- [ ] **Rollback Plan**: Prepare rollback procedure
- [ ] **Monitoring**: Set up alerts for migration monitoring
- [ ] **Communication**: Notify stakeholders about maintenance

## Initial Database Setup

### 1. Create Production Database

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# Create database and user
CREATE DATABASE a2d2_production;
CREATE USER a2d2_user WITH ENCRYPTED PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE a2d2_production TO a2d2_user;

# Grant schema privileges
\c a2d2_production
GRANT ALL ON SCHEMA public TO a2d2_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO a2d2_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO a2d2_user;

\q
```

### 2. Configure Database Connection

Edit `config/database.yml` or use environment variables:

```yaml
production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  url: <%= ENV['DATABASE_URL'] %>
  prepared_statements: false
  advisory_locks: false
```

### 3. Run Initial Migrations

```bash
cd /var/www/a2d2/current

# Load schema
RAILS_ENV=production bundle exec rails db:schema:load

# Or run migrations from scratch
RAILS_ENV=production bundle exec rails db:migrate

# Load seed data if needed
RAILS_ENV=production bundle exec rails db:seed
```

## Ongoing Migration Procedures

### Migration Workflow

```
┌─────────────────┐
│  Write Migration│
└────────┬────────┘
         │
┌────────▼────────┐
│  Review & Test  │ (development)
└────────┬────────┘
         │
┌────────▼────────┐
│  Test on Staging│
└────────┬────────┘
         │
┌────────▼────────┐
│  Backup Prod DB │
└────────┬────────┘
         │
┌────────▼────────┐
│  Run on Prod    │
└────────┬────────┘
         │
┌────────▼────────┐
│  Verify Results │
└─────────────────┘
```

### Running Migrations in Production

#### Standard Migration (with downtime)

```bash
#!/bin/bash
# File: scripts/migrate-production.sh

set -e

echo "Starting production migration..."

# 1. Backup database
echo "Creating backup..."
BACKUP_FILE="/var/backups/postgresql/a2d2_$(date +%Y%m%d_%H%M%S).dump"
pg_dump -h localhost -U a2d2_user -F c -b -v -f "$BACKUP_FILE" a2d2_production
echo "Backup saved to: $BACKUP_FILE"

# 2. Put application in maintenance mode
echo "Enabling maintenance mode..."
sudo systemctl stop a2d2-web
sudo systemctl stop a2d2-worker

# 3. Run migrations
echo "Running migrations..."
cd /var/www/a2d2/current
RAILS_ENV=production bundle exec rails db:migrate

# 4. Check migration status
echo "Verifying migrations..."
RAILS_ENV=production bundle exec rails db:migrate:status

# 5. Restart application
echo "Restarting application..."
sudo systemctl start a2d2-worker
sudo systemctl start a2d2-web

# 6. Health check
sleep 10
curl -f http://localhost:3000/health || {
    echo "Health check failed! Rolling back..."
    RAILS_ENV=production bundle exec rails db:rollback
    sudo systemctl restart a2d2-web a2d2-worker
    exit 1
}

echo "Migration completed successfully!"
```

Make it executable:

```bash
chmod +x scripts/migrate-production.sh
```

### Zero-Downtime Migrations

For migrations that don't require downtime, follow these patterns:

#### Pattern 1: Adding a New Column

```ruby
# Good: Adding column with default (in multiple steps)
class AddStatusToDocuments < ActiveRecord::Migration[8.0]
  def change
    # Step 1: Add column without default
    add_column :documents, :status, :string

    # Step 2: Backfill in batches (in a separate migration)
    # Step 3: Add default and NOT NULL constraint (in another migration)
  end
end
```

#### Pattern 2: Removing a Column

```ruby
# Step 1: Mark column as ignored in model
class Document < ApplicationRecord
  self.ignored_columns = [:old_field]
end

# Deploy this first, then in next release:
class RemoveOldFieldFromDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :documents, :old_field, :string
  end
end
```

#### Pattern 3: Adding an Index

```ruby
# Add index concurrently (doesn't lock table)
class AddIndexToDocumentsStatus < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :documents, :status, algorithm: :concurrently
  end
end
```

#### Pattern 4: Renaming a Column

```ruby
# Step 1: Add new column
class AddNewNameToDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :documents, :new_name, :string
  end
end

# Step 2: Backfill data
class BackfillNewNameInDocuments < ActiveRecord::Migration[8.0]
  def up
    Document.in_batches.update_all("new_name = old_name")
  end
end

# Step 3: Update application to use new_name
# Deploy application changes

# Step 4: Remove old column (in next release)
class RemoveOldNameFromDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :documents, :old_name, :string
  end
end
```

## Migration Best Practices

### Writing Safe Migrations

```ruby
class SafeMigrationExample < ActiveRecord::Migration[8.0]
  # 1. Disable transactions for long-running migrations
  disable_ddl_transaction!

  def change
    # 2. Set statement timeout (5 minutes)
    safety_assured do
      execute "SET statement_timeout = '300s'"
    end

    # 3. Add indexes concurrently
    add_index :large_table, :column_name, algorithm: :concurrently

    # 4. Use batching for data updates
    reversible do |dir|
      dir.up do
        LargeModel.in_batches(of: 1000).each do |batch|
          batch.update_all(status: 'pending')
          sleep(0.1) # Be gentle on the database
        end
      end
    end
  end

  def down
    # Always provide rollback logic
    remove_index :large_table, :column_name
  end
end
```

### Migration Anti-Patterns (Avoid These!)

❌ **Don't**: Add column with default in one migration on large table
```ruby
# This locks the table!
add_column :large_table, :status, :string, default: 'pending', null: false
```

✅ **Do**: Split into multiple migrations
```ruby
# Migration 1
add_column :large_table, :status, :string

# Migration 2 (separate deploy)
change_column_default :large_table, :status, 'pending'

# Migration 3 (after backfill)
change_column_null :large_table, :status, false
```

❌ **Don't**: Remove column immediately
```ruby
remove_column :table, :column  # App will crash if still referenced!
```

✅ **Do**: Use multi-step deprecation
```ruby
# 1. Ignore in model, deploy
# 2. Remove column in next deploy
```

## Monitoring Migrations

### Real-time Migration Monitoring

```bash
# Watch migration progress
watch -n 1 'sudo -u postgres psql -c "SELECT * FROM pg_stat_activity WHERE state = '\''active'\'' AND query LIKE '\''%ALTER TABLE%'\'';"'

# Check for locks
sudo -u postgres psql -c "SELECT * FROM pg_locks WHERE NOT granted;"

# Monitor table bloat
sudo -u postgres psql -d a2d2_production -c "
  SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
  FROM pg_tables
  WHERE schemaname = 'public'
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC
  LIMIT 10;
"
```

### Migration Logging

Enable detailed logging:

```ruby
# config/environments/production.rb
config.active_record.verbose_query_logs = true
config.active_record.logger = ActiveSupport::Logger.new('log/migrations.log')
```

## Rollback Procedures

### Automatic Rollback

```bash
# Rollback last migration
RAILS_ENV=production bundle exec rails db:rollback

# Rollback specific number of migrations
RAILS_ENV=production bundle exec rails db:rollback STEP=3

# Rollback to specific version
RAILS_ENV=production bundle exec rails db:migrate:down VERSION=20251028120000
```

### Manual Rollback (from backup)

```bash
#!/bin/bash
# File: scripts/restore-from-backup.sh

set -e

BACKUP_FILE=$1

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file>"
    exit 1
fi

echo "WARNING: This will restore database from backup!"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

# Stop application
echo "Stopping application..."
sudo systemctl stop a2d2-web a2d2-worker

# Drop and recreate database
echo "Restoring database..."
sudo -u postgres psql << EOF
SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'a2d2_production';
DROP DATABASE IF EXISTS a2d2_production;
CREATE DATABASE a2d2_production;
GRANT ALL PRIVILEGES ON DATABASE a2d2_production TO a2d2_user;
EOF

# Restore from backup
pg_restore -h localhost -U a2d2_user -d a2d2_production -v "$BACKUP_FILE"

# Restart application
echo "Restarting application..."
sudo systemctl start a2d2-worker a2d2-web

echo "Database restored successfully!"
```

## Data Backfill Scripts

### Example: Backfill with Progress Tracking

```ruby
# lib/tasks/backfill_document_status.rake
namespace :data do
  desc "Backfill document status field"
  task backfill_document_status: :environment do
    total = Document.where(status: nil).count
    processed = 0

    puts "Starting backfill of #{total} documents..."

    Document.where(status: nil).find_each(batch_size: 1000) do |doc|
      doc.update_column(:status, determine_status(doc))

      processed += 1
      if processed % 1000 == 0
        progress = (processed.to_f / total * 100).round(2)
        puts "Progress: #{processed}/#{total} (#{progress}%)"
      end

      # Be gentle on the database
      sleep(0.01) if processed % 100 == 0
    end

    puts "Backfill completed! Processed #{processed} documents."
  end

  private

  def determine_status(doc)
    # Your status logic here
    'pending'
  end
end
```

Run backfill:

```bash
RAILS_ENV=production bundle exec rake data:backfill_document_status
```

## Performance Considerations

### Index Strategy

```ruby
# Create indexes before loading data
class OptimizedMigration < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.text :content
      t.string :status
      t.timestamps
    end

    # Add indexes immediately for new tables
    add_index :documents, :status
    add_index :documents, :created_at
    add_index :documents, [:status, :created_at]
  end
end
```

### Batch Processing

```ruby
# Process in batches to avoid memory issues
class BatchProcessingMigration < ActiveRecord::Migration[8.0]
  def up
    say_with_time "Processing documents in batches" do
      Document.in_batches(of: 500) do |batch|
        batch.update_all(updated_at: Time.current)
      end
    end
  end
end
```

## Troubleshooting

### Common Issues

#### 1. Migration Stuck/Hanging

```sql
-- Check for blocking queries
SELECT
  pid,
  usename,
  pg_blocking_pids(pid) as blocked_by,
  query as blocked_query
FROM pg_stat_activity
WHERE cardinality(pg_blocking_pids(pid)) > 0;

-- Kill blocking query (careful!)
SELECT pg_terminate_backend(pid);
```

#### 2. Migration Failed Midway

```bash
# Check migration status
RAILS_ENV=production bundle exec rails db:migrate:status

# Fix and re-run
RAILS_ENV=production bundle exec rails db:migrate
```

#### 3. Disk Space Issues

```bash
# Check disk space
df -h

# Clean up old logs
sudo journalctl --vacuum-time=7d

# Vacuum database
sudo -u postgres psql -d a2d2_production -c "VACUUM FULL VERBOSE;"
```

## Migration Checklist Template

Use this checklist for every production migration:

```markdown
## Migration Checklist: [Migration Name]

### Pre-Migration
- [ ] Migration tested in development
- [ ] Migration tested on staging
- [ ] Database backup created
- [ ] Rollback procedure documented
- [ ] Team notified of maintenance window
- [ ] Monitoring alerts configured

### During Migration
- [ ] Application in maintenance mode (if needed)
- [ ] Migration started: [TIMESTAMP]
- [ ] Migration monitoring active
- [ ] Progress logged

### Post-Migration
- [ ] Migration completed: [TIMESTAMP]
- [ ] Application restarted
- [ ] Health checks passing
- [ ] Smoke tests completed
- [ ] Performance metrics normal
- [ ] Team notified of completion

### Rollback (if needed)
- [ ] Issue identified: [DESCRIPTION]
- [ ] Rollback initiated
- [ ] Database restored
- [ ] Application verified
- [ ] Incident report created
```

## Next Steps

- Review [Zero-Downtime Deployment](zero-downtime.md)
- Configure [Health Checks](health-checks.md)
- Set up [Rollback Procedures](rollback-guide.md)

## References

- [Rails Migrations Guide](https://guides.rubyonrails.org/active_record_migrations.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/current/sql-altertable.html)
- [Strong Migrations Gem](https://github.com/ankane/strong_migrations)

---

**Document Version**: 1.0
**Last Updated**: 2025-10-28
**Maintainer**: A2D2 DevOps Team
