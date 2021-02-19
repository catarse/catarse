# frozen_string_literal: true

FactoryBot.define do
  factory :bank do
    name { 'Foo' }
    sequence(:code, 900)
  end
end
