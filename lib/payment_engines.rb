class PaymentEngines
  def self.register options
    @@engines ||= []
    @@engines.push(options)
  end

  def self.clear
    @@engines.clear
  end

  def self.engines
    @@engines.sort{|a,b| (a[:locale] == I18n.locale.to_s ? -1 : 1) }
  end

  def self.confirm! filter
    find_payment(filter).confirm!
  end

  def self.refund! filter
    find_payment(filter).refund!
  end

  def self.cancel! filter
    find_payment(filter).cancel!
  end

  def self.create_payment_notification filter, data
    find_payment(filter).payment_notifications.create extra_data: data
  end

  def self.update_payment_data filter, attributes
    find_payment(filter).update_attributes attributes
  end

  protected
  def self.find_payment filter
    Backer.where(filter).first
  end
end
