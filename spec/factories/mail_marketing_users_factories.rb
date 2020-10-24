FactoryBot.define do
  factory :mail_marketing_user do
    association :user
    association :mail_marketing_list
  end
end
