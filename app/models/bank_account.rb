class BankAccount < ActiveRecord::Base
  include CatarsePagarme::BankAccountConcern

  belongs_to :user
  belongs_to :bank

  validates :bank_id, :agency, :account, :owner_name, :owner_document, :account_digit, presence: true

  def bank_code
    self.bank.code
  end

  def complete_agency_string
    return agency unless agency_digit.present?
    "#{agency} - #{agency_digit}"
  end

  def complete_account_string
    "#{account} - #{account_digit}"
  end
end
