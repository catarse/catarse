# frozen_string_literal: true

FactoryBot.define do
  factory :post_reward do
    association :project_post
    association :reward
  end
end
