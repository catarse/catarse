module Shared::BankAccountHelper
  extend ActiveSupport::Concern

  included do
    validates :account, format: { with: /\A\d+\z/ }

    # if input_bank_number as present, we
    # should validate if the number matchs with any
    # bank.code on database
    def input_bank_number_validation
      if self.input_bank_number.present? && !self.bank_from_input_number.present?
        self.errors.add(:input_bank_number, :invalid)
      end
    end

    def bank_code
      self.bank.code
    end

    # set bank attribute with founded bank via
    # input_bank_number virtual attribute
    def load_bank_from_input_bank_number
      if self.bank_from_input_number.present?
        self.bank = self.bank_from_input_number
      end
    end

    # Returns a bank object that bank number
    # matches with Bank.code
    def bank_from_input_number
      Bank.find_by_code self.input_bank_number
    end
  end

end
