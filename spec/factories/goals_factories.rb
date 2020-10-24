FactoryBot.define do
  factory :goal do
    association :project
    value { 10.00 }
    description { 'Foo bar' }
    title { 'Foo bar' }
  end
end
