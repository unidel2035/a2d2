FactoryBot.define do
  factory :cell do
    association :row
    column_key { ("A".."Z").to_a.sample }
    value { "Sample Value" }
    data_type { "string" }
    formula { nil }

    trait :with_integer do
      value { "42" }
      data_type { "integer" }
    end

    trait :with_decimal do
      value { "3.14" }
      data_type { "decimal" }
    end

    trait :with_boolean do
      value { "true" }
      data_type { "boolean" }
    end

    trait :with_date do
      value { Date.today.to_s }
      data_type { "date" }
    end

    trait :with_formula do
      formula { "=A1+B1" }
      value { nil }
    end
  end
end
