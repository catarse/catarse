FactoryBot.define do
  factory :donation do
    association :user
    amount { 10 }
  end
end
