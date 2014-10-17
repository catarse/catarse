class BankAccount < ActiveRecord::Base
  belongs_to :user
  belongs_to :bank

  validates :bank_id, :agency, :account, :owner_name, :owner_document, :account_digit, presence: true

  def bank_code
    self.bank.code
  end
end
