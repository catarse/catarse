FactoryBot.define do
  factory :state do
    name { generate(:name) }
    acronym { generate(:name) }
  end
end
