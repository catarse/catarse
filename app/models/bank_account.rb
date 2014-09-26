class BankAccount < ActiveRecord::Base
  belongs_to :user

  validates :name, :agency, :agency_digit, :account, :user_name, :user_document, :account_digit, presence: true

  def bank_code
    $1 if name.match(/(\w+) \- .*/)
  end
end
