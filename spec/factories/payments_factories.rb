# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    association :contribution
    gateway { 'Pagarme' }
    value { 10.00 }
    installment_value { 10.00 }
    payment_method { 'CartaoDeCredito' }
    gateway_data { {} }
    gateway_fee { 1.00 }
  end
end
