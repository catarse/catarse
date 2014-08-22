class CreditCard < ActiveRecord::Base
  belongs_to :user

  validates :user, :last_digits, :card_brand, :object_id, presence: true
end
