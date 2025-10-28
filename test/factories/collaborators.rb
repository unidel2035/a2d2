FactoryBot.define do
  factory :collaborator do
    association :spreadsheet
    user_id { create(:user).id }
    email { nil }
    permission { "view" }

    trait :with_email do
      user_id { nil }
      email { Faker::Internet.email }
    end

    trait :editor do
      permission { "edit" }
    end

    trait :admin do
      permission { "admin" }
    end
  end
end
