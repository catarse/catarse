FactoryBot.define do
  factory :balance_transaction do
    association :user
    association :project
    association :contribution
    amount { 100 }
    event_name { 'foo' }
  end
end
