# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    name { generate(:name) }
    acronym { generate(:name) }
  end
end
