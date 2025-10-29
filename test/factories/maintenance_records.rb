FactoryBot.define do
  factory :maintenance_record do
    association :robot
    association :technician, factory: :user, role: :technician
    scheduled_date { 1.week.from_now }
    maintenance_type { :routine }
    status { :scheduled }
    description { "Regular maintenance check" }

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
      completed_date { Date.current }
      cost { 1500.00 }
      description { "Completed maintenance with component replacement" }
      next_maintenance_date { 6.months.from_now }
      operation_hours_at_maintenance { 1200.0 }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :overdue do
      status { :scheduled }
      scheduled_date { 1.week.ago }
    end

    trait :repair do
      maintenance_type { :repair }
      description { "Repair work required" }
    end

    trait :component_replacement do
      maintenance_type { :component_replacement }
      description { "Component replacement" }
      replaced_components { ["battery", "sensor module"] }
    end
  end
end
