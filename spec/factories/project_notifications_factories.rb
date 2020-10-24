FactoryBot.define do
  factory :project_notification do
    association :user, factory: :user
    association :project, factory: :project
    template_name { 'project_success' }
    from_email { 'from@email.com' }
    from_name { 'from_name' }
    locale { 'pt' }
  end
end
