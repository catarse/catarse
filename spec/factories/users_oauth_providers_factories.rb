FactoryBot.define do
  factory :users_oauth_provider, class: 'UsersOauthProviders' do
    oauth_provider { 1 }
    user_id { 1 }
    uid { 'MyText' }
  end
end
