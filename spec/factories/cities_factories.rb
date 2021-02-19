# frozen_string_literal: true

FactoryBot.define do
  factory :city do
    association :state
    name { 'foo' }
  end
end
