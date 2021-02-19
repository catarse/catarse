# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name_pt { generate(:name) }
  end
end
