class PaymentEngines
  @@engines = []

  def self.register options
    @@engines.push(options)
  end

  def self.clear
    @@engines.clear
  end

  def self.engines
    @@engines.sort{|a,b| (a[:locale] == I18n.locale.to_s ? -1 : 1) }
  end

  def self.create_payment_notification attributes
    PaymentNotification.create! attributes
  end

  def self.configuration
    ::Configuration
  end

  def self.find_payment filter
    Backer.where(filter).first
  end
end
