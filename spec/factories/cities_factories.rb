FactoryBot.define do
  factory :city do
    association :state
    name { 'foo' }
  end
end
