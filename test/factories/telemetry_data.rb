FactoryBot.define do
  factory :telemetry_data do
    association :robot
    association :task, optional: true
    recorded_at { Time.current }
    data { { "temperature" => 25.0, "humidity" => 60.0 } }
    location { "Factory Floor" }
    latitude { 40.7128 + rand(-0.1..0.1) }
    longitude { -74.0060 + rand(-0.1..0.1) }
    altitude { 10.0 + rand(0..50) }
    sensors { { "battery" => rand(50..100), "signal_strength" => rand(60..100) } }

    trait :with_location do
      latitude { 40.7128 }
      longitude { -74.0060 }
      altitude { 15.5 }
    end

    trait :without_location do
      latitude { nil }
      longitude { nil }
      altitude { nil }
    end

    trait :low_battery do
      sensors { { "battery" => 15, "signal_strength" => 80 } }
    end
  end
end
