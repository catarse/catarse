# frozen_string_literal: true

class PaymentEngines
  def self.new_payment(attributes={})
    Payment.new attributes
  end

  def self.find_contribution(id)
    Contribution.find id
  end

  def self.find_payment filter
    Payment.where(filter).first
  end

  def self.was_credit_card_used_before?(card_id)
    Payment.where(state: 'paid').where("gateway_data -> 'card' ->> 'id' = ?", card_id).exists?
  end
end
