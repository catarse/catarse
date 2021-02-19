# frozen_string_literal: true

FactoryBot.define do
  factory :origin do
    referral { generate(:permalink) }
    domain { generate(:domain) }
  end
end
