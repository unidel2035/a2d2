FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "SecurePassword123!" }
    password_confirmation { "SecurePassword123!" }
    name { "Test User" }
    first_name { "Test" }
    last_name { "User" }
    role { :viewer }
    data_processing_consent { true }
    privacy_policy_accepted_at { Time.current }
    terms_of_service_accepted_at { Time.current }
    confirmed_at { Time.current }

    trait :operator do
      role { :operator }
      license_number { "OP-12345" }
      license_expiry { 1.year.from_now }
    end

    trait :technician do
      role { :technician }
      license_number { "TECH-12345" }
      license_expiry { 1.year.from_now }
    end

    trait :admin do
      role { :admin }
    end

    trait :license_expired do
      license_number { "EXP-12345" }
      license_expiry { 1.day.ago }
    end
  end
end
