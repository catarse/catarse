# frozen_string_literal: true

FactoryBot.define do
  factory :project_fiscal do
    association :project
    association :user
    metadata { {} }
    total_amount_cents { Faker::Number.number(digits: 4) }
    total_catarse_fee_cents { Faker::Number.number(digits: 4) }
    total_gateway_fee_cents { Faker::Number.number(digits: 4) }
    total_antifraud_fee_cents { Faker::Number.number(digits: 4) }
    total_chargeback_cost_cents { Faker::Number.number(digits: 4) }
    begin_date { Time.zone.now.to_date.beginning_of_month }
    end_date { Time.zone.now.to_date.end_of_month }
  end
end
