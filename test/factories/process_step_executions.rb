FactoryBot.define do
  factory :process_step_execution do
    association :process_execution
    association :process_step
    status { "pending" }
    input_data { {} }
    output_data { {} }
    started_at { nil }
    completed_at { nil }

    trait :running do
      status { "running" }
      started_at { Time.current }
    end

    trait :completed do
      status { "completed" }
      started_at { 10.minutes.ago }
      completed_at { Time.current }
      output_data { { "result" => "success" } }
    end

    trait :failed do
      status { "failed" }
      started_at { 10.minutes.ago }
      completed_at { Time.current }
      error_message { "Step execution failed" }
    end
  end
end
