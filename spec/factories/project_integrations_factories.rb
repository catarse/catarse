FactoryBot.define do
  factory :project_integration do
    association :project
    name { 'GA' }
    data { { data: { id: 'UA-12345678-1' } } }
  end
end
