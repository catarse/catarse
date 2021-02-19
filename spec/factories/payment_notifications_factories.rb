# frozen_string_literal: true

FactoryBot.define do
  factory :payment_notification do
    association :contribution
    extra_data { {} }
  end
end
