FactoryBot.define do
  factory :project_reminder do
    association :user
    association :project
  end
end
