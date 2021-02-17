# frozen_string_literal: true

FactoryBot.define do
  factory :balance_transfer do
    association :project
    association :user, :with_bank_account

    amount { 50 }

    transient do
      transition_state { 'pending' }
    end

    after :create do |balance_transfer, evaluator|
      create(:balance_transfer_transition,
        to_state: evaluator.transition_state,
        balance_transfer: balance_transfer,
        most_recent: false
      )
    end
  end
end