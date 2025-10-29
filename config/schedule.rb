# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Learn more: http://github.com/javan/whenever

# Set environment
set :environment, ENV.fetch("RAILS_ENV", "production")

# Set output for logging
set :output, { error: "log/cron_error.log", standard: "log/cron.log" }

# ROB-004: Проверка предстоящих технических обслуживаний
# Выполняется ежедневно в 9:00 утра
every 1.day, at: "9:00 am" do
  runner "MaintenanceNotificationJob.perform_now"
end

# ANL-005: Сбор метрик системы
# Выполняется каждый час
every 1.hour do
  runner "MetricCollectionJob.perform_now"
end

# Проверка дедлайнов задач
# Выполняется каждые 15 минут
every 15.minutes do
  runner "DeadlineCheckerJob.perform_now"
end

# Очистка старых данных в памяти агентов
# Выполняется ежедневно в 2:00 ночи
every 1.day, at: "2:00 am" do
  runner "MemoryPruningJob.perform_now"
end
