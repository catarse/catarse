FactoryBot.define do
  factory :authorization do
    association :oauth_provider
    association :user
    uid { 'Foo' }
  end
end
