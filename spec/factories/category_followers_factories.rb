FactoryBot.define do
  factory :category_follower do
    association :user
    association :category
  end
end
