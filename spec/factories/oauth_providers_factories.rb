FactoryBot.define do
  factory :oauth_provider do
    name { 'facebook' }
    strategy { 'GitHub' }
    path { 'github' }
    key { 'test_key' }
    secret { 'test_secret' }
  end
end
