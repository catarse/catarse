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
end
