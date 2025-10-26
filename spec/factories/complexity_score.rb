# frozen_string_literal: true

FactoryBot.define do
  factory :complexity_score do
    job_id { SecureRandom.hex(8) }
    status { 'pending' }
    words { %w[happy sad angry].to_json }
    result { nil }

    trait :in_progress do
      status { 'in_progress' }
    end

    trait :completed do
      status { 'completed' }
      result { { 'happy' => 3.5, 'sad' => 2.8, 'angry' => 3.2 }.to_json }
    end

    trait :failed do
      status { 'failed' }
      result { 'API error occurred' }
    end
  end
end
