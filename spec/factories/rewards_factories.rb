FactoryBot.define do
  factory :reward do
    association :project
    minimum_value { 10.00 }
    description { 'Foo bar' }
    shipping_options { 'free' }
    deliver_at { 1.year.from_now }
  end
end
