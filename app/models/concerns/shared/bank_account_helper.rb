# frozen_string_literal: true

module Shared::BankAccountHelper
  extend ActiveSupport::Concern

  included do
    validates :account, format: { with: /\A\d+\z/ }

    # if input_bank_number as present, we
    # should validate if the number matchs with any
    # bank.code on database
    def input_bank_number_validation
      if input_bank_number.present? && !bank_from_input_number.present?
        errors.add(:input_bank_number, :invalid)
      end
    end

    def bank_code
      bank.code
    end

    # set bank attribute with founded bank via
    # input_bank_number virtual attribute
    def load_bank_from_input_bank_number
      self.bank = bank_from_input_number if bank_from_input_number.present?
    end

    # Returns a bank object that bank number
    # matches with Bank.code
    def bank_from_input_number
      Bank.find_by_code input_bank_number
    end
  end
end
