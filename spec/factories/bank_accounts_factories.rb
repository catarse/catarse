FactoryBot.define do
  factory :bank_account do
    association :user
    association :bank
    input_bank_number { nil }
    # owner_name { "Foo Bar" }
    # owner_document { "97666238991" }
    account_digit { '1' }
    agency { '1234' }
    agency_digit { '1' }
    account { '12345' }
  end
end
