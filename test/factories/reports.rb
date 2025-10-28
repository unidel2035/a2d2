FactoryBot.define do
  factory :report do
    association :user
    name { "Monthly Performance Report" }
    report_type { "pdf" }
    status { :active }
    parameters { { "metrics" => ["total_tasks", "avg_duration"], "date_range" => "last_month" } }
    schedule { {} }

    trait :with_schedule do
      schedule { { "frequency" => "daily", "time" => "09:00" } }
      next_generation_at { 1.day.from_now }
    end

    trait :scheduled_weekly do
      schedule { { "frequency" => "weekly", "day" => "monday", "time" => "08:00" } }
      next_generation_at { 1.week.from_now }
    end

    trait :scheduled_monthly do
      schedule { { "frequency" => "monthly", "day_of_month" => 1, "time" => "00:00" } }
      next_generation_at { 1.month.from_now }
    end

    trait :excel do
      report_type { "excel" }
    end

    trait :csv do
      report_type { "csv" }
    end

    trait :generating do
      status { :generating }
    end

    trait :failed do
      status { :failed }
    end
  end
end
