FactoryBot.define do
  factory :project_invite do
    association :project
    user_email { generate(:user_email) }
  end
end
