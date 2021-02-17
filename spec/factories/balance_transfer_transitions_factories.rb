# frozen_string_literal: true

FactoryBot.define do
  factory :balance_transfer_transition do
    to_state { 'pending' }
    sort_key { 0 }
    most_recent { true }

    before :create do |transition|
      transition.sort_key = 1 if transition.to_state == 'authorized'
    end
  end
end
