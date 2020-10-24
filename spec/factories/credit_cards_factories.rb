FactoryBot.define do
  factory :credit_card do
    association :user
    last_digits { '1234' }
    card_brand { 'Foo' }
  end
end
