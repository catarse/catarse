# frozen_string_literal: true

FactoryBot.define do
  factory :antifraud_analysis do
    association :payment, factory: :country

    cost { 10.00 }
  end
end
