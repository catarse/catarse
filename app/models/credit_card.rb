class CreditCard < ActiveRecord::Base
  belongs_to :user

  validates :user, :last_digits, :card_brand, :subscription_id, presence: true
  delegate :display_digits, to: :decorator

  def decorator
    CreditCardDecorator.new(self)
  end

  def cancel_subscription
    if defined?(CatarsePagarme)
      self.pagarme_delegator.cancel_subscription
    end
  end
end
