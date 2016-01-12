class BankAccount < ActiveRecord::Base
  include CatarsePagarme::BankAccountConcern
  include Shared::BankAccountHelper

  belongs_to :user
  belongs_to :bank

  validates :bank_id, :agency, :account,
    :owner_name, :owner_document, :account_digit, presence: true

  attr_accessor :input_bank_number
  validate :input_bank_number_validation

  # before validate bank account we inject the founded
  # bank account via input_bank_number
  before_validation :load_bank_from_input_bank_number

  def complete_agency_string
    return agency unless agency_digit.present?
    "#{agency} - #{agency_digit}"
  end

  def complete_account_string
    "#{account} - #{account_digit}"
  end
end
