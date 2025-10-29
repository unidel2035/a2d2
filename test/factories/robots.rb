FactoryBot.define do
  factory :robot do
    sequence(:serial_number) { |n| "ROBOT-#{n.to_s.rjust(4, '0')}" }
    model { "AgriBot-X1" }
    manufacturer { "AgriTech Industries" }
    manufacture_date { 1.year.ago }
    status { :active }
    last_maintenance_date { 3.months.ago }
    total_operation_hours { 1000 }
    location { "Field Section A" }
    description { "Agricultural robot for crop monitoring and maintenance" }

    trait :maintenance do
      status { :maintenance }
    end

    trait :repair do
      status { :repair }
    end

    trait :retired do
      status { :retired }
    end

    trait :needs_maintenance do
      last_maintenance_date { 7.months.ago }
    end
  end
end
