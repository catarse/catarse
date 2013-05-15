class PaymentEngines
  cattr_accessor :backer

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

  def self.find_payment filter
    self.backer = Backer.where(filter).first
  end
end
