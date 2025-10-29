FactoryBot.define do
  factory :task do
    association :robot
    association :operator, factory: :user, optional: true
    task_number { nil } # Will be auto-generated
    description { "Sample task description" }
    status { :planned }
    task_type { "inspection" }
    planned_date { 1.day.from_now }
    location { "Factory Floor A" }

    trait :in_progress do
      status { :in_progress }
      actual_start { Time.current }
    end

    trait :completed do
      status { :completed }
      actual_start { 2.hours.ago }
      actual_end { Time.current }
      duration { 120 } # minutes
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :overdue do
      status { :planned }
      planned_date { 1.day.ago }
    end
  end
end
