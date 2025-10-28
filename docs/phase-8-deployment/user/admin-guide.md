# DOC-USER-002: Administrator Guide

**Version**: 1.0
**Last Updated**: 2025-10-28
**Audience**: System Administrators

## User Management

### Creating Users
```bash
# Via Rails console
RAILS_ENV=production rails console
User.create!(email: 'user@example.com', password: 'secure_pass', role: 'user')
```

### Roles and Permissions
- **Admin**: Full system access
- **Manager**: Create/manage processes, view all documents
- **User**: Basic access to own documents and processes
- **Viewer**: Read-only access

### Managing Licenses
```ruby
# Check license usage
License.current_usage
# => { users: 45, max_users: 50, ai_agents: 10, processes: 120 }
```

## System Configuration

### Environment Variables
```bash
# Core settings
RAILS_ENV=production
SECRET_KEY_BASE=<generate_with_rails_secret>

# Database
DATABASE_URL=postgresql://user:pass@host:5432/db
DATABASE_REPLICA_URL=postgresql://user:pass@replica:5432/db

# Redis
REDIS_URL=redis://:password@host:6379/0
REDIS_CACHE_URL=redis://:password@host:6379/1

# LLM APIs
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
DEEPSEEK_API_KEY=...
```

### Application Settings
Located in `config/settings.yml`:
```yaml
production:
  max_upload_size: 100 # MB
  session_timeout: 30 # minutes
  enable_2fa: true
  log_level: info
  retention_days: 90
```

## Backup and Restore

### Automated Backups
```bash
# Daily backup script (runs via cron)
/var/www/a2d2/scripts/backup-daily.sh
```

### Manual Backup
```bash
# Database
pg_dump -U a2d2_user -F c -b a2d2_production > backup.dump

# Files
tar -czf uploads-backup.tar.gz /var/www/a2d2/shared/storage
```

### Restore
```bash
# Database
pg_restore -U a2d2_user -d a2d2_production backup.dump

# Files
tar -xzf uploads-backup.tar.gz -C /var/www/a2d2/shared/
```

## Monitoring

### Key Metrics
- Response time: <2s (95th percentile)
- Error rate: <0.1%
- CPU usage: <70%
- Memory usage: <80%
- Disk usage: <85%
- Queue size: <1000 pending jobs

### Accessing Monitoring
- **Grafana**: http://your-server:3001
- **Prometheus**: http://your-server:9090
- **Logs**: `/var/log/a2d2/`

### Log Locations
```
/var/log/a2d2/
├── production.log       # Application logs
├── web.log             # Web server logs
├── worker.log          # Background job logs
└── error.log           # Error logs
```

## Performance Tuning

### Database Optimization
```sql
-- Vacuum database
VACUUM ANALYZE;

-- Reindex
REINDEX DATABASE a2d2_production;

-- Check slow queries
SELECT query, mean_exec_time 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 10;
```

### Redis Optimization
```bash
# Clear cache
redis-cli FLUSHDB

# Check memory
redis-cli INFO memory
```

### Application Tuning
```ruby
# config/puma.rb
workers ENV.fetch("WEB_CONCURRENCY") { 4 }
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count
```

## Security

### SSL Certificate Renewal
```bash
# Let's Encrypt auto-renewal
sudo certbot renew --dry-run
```

### Security Audits
```bash
# Run security scan
bundle exec brakeman -o brakeman-report.html

# Check gem vulnerabilities
bundle exec bundler-audit check --update
```

### Firewall Rules
```bash
# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow SSH (change port as needed)
sudo ufw allow 22/tcp

# Enable firewall
sudo ufw enable
```

## Troubleshooting

### Common Issues

**Issue**: Application not responding
```bash
# Check services
sudo systemctl status a2d2-web a2d2-worker

# Restart if needed
sudo systemctl restart a2d2-web a2d2-worker
```

**Issue**: High database CPU
```sql
-- Find long-running queries
SELECT pid, age(clock_timestamp(), query_start), query
FROM pg_stat_activity
WHERE state != 'idle' AND query NOT LIKE '%pg_stat_activity%'
ORDER BY query_start;

-- Kill problematic query
SELECT pg_terminate_backend(pid);
```

**Issue**: Disk space low
```bash
# Check disk usage
df -h

# Clean old logs
sudo journalctl --vacuum-time=7d

# Clean old releases
cd /var/www/a2d2/releases
ls -t | tail -n +6 | xargs rm -rf
```

## Maintenance Tasks

### Weekly
- [ ] Review error logs
- [ ] Check disk space
- [ ] Monitor performance metrics
- [ ] Review security alerts

### Monthly
- [ ] Apply security updates
- [ ] Review user access
- [ ] Clean up old data
- [ ] Test backup restore
- [ ] Update documentation

### Quarterly
- [ ] Security audit
- [ ] Performance review
- [ ] Capacity planning
- [ ] User training sessions

## Support Contacts

- **DevOps Team**: devops@example.com
- **Security Team**: security@example.com
- **On-Call**: +7 (XXX) XXX-XX-XX

---

**Document Version**: 1.0
**Last Updated**: 2025-10-28
