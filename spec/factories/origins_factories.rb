FactoryBot.define do
  factory :origin do
    referral { generate(:permalink) }
    domain { generate(:domain) }
  end
end
