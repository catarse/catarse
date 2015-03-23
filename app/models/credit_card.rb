class CreditCard < ActiveRecord::Base
  belongs_to :user

  validates :user, :last_digits, :card_brand, presence: true

  def decorator
    CreditCardDecorator.new(self)
  end

  def display_digits
    "XXXX-XXXX-XXXX-#{last_digits}"
  end
end
