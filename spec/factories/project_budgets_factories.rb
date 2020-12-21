FactoryBot.define do
  factory :project_budget do
    association :project
    name { 'Foo Bar' }
    value { '10' }
  end
end
