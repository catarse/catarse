FactoryBot.define do
  factory :payment do
    association :contribution
    gateway { 'Pagarme' }
    value { 10.00 }
    installment_value { 10.00 }
    payment_method { 'CartaoDeCredito' }
    gateway_data { {} }
  end
end
