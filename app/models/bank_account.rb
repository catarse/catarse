class BankAccount < ActiveRecord::Base
  include CatarsePagarme::BankAccountConcern

  belongs_to :user
  belongs_to :bank

  validates :bank_id, :agency, :account,
    :owner_name, :owner_document, :account_digit, presence: true

  attr_accessor :input_bank_number
  validate :input_bank_number_validation

  # before validate bank account we inject the founded
  # bank account via input_bank_number
  before_validation :load_bank_from_input_bank_number

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

  def complete_agency_string
    return agency unless agency_digit.present?
    "#{agency} - #{agency_digit}"
  end

  def complete_account_string
    "#{account} - #{account_digit}"
  end
end
