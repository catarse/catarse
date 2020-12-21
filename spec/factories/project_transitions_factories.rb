FactoryBot.define do
  factory :project_transition do
    association :project
    most_recent { true }
    to_state { 'online' }
    sort_key { generate(:serial) }
  end
end
