class CreditCard < ActiveRecord::Base
  belongs_to :user

  validates :user, :last_digits, :card_brand, :subscription_id, presence: true
end
