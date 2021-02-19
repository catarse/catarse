# frozen_string_literal: true

FactoryBot.define do
  factory :balance_transfer do
    association :project
    association :user, :with_bank_account

    amount { 50 }
  end
end
