# frozen_string_literal: true

FactoryBot.define do
  factory :user_link do
    association :user
    link { 'http://www.foo.com' }
  end
end
