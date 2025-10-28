FactoryBot.define do
  factory :process_execution do
    association :process
    association :user, optional: true
    status { :pending }
    input_data { { "source" => "test" } }
    output_data { {} }

    trait :running do
      status { :running }
      started_at { Time.current }
    end

    trait :completed do
      status { :completed }
      started_at { 1.hour.ago }
      completed_at { Time.current }
      output_data { { "result" => "success" } }
    end

    trait :failed do
      status { :failed }
      started_at { 1.hour.ago }
      completed_at { Time.current }
      error_message { "Test error message" }
    end

    trait :cancelled do
      status { :cancelled }
      completed_at { Time.current }
    end
  end
end
