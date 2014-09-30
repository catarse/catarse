class Bank < ActiveRecord::Base
  has_many :bank_accounts

  validates :name, :code, presence: true
end
