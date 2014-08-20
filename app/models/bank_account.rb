class BankAccount < ActiveRecord::Base
  belongs_to :user

  validates :name, :agency, :account, :user_name, :user_document, :account_digit, presence: true
end
