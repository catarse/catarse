class PaymentEngines
  cattr_reader :engines

  def self.register options
    @@engines ||= []
    @@engines.push(options)
  end

  def self.clear
    @@engines.clear
  end

  def self.each
    @@engines.sort{|a,b| (a[:locale] == I18n.locale.to_s ? -1 : 1) }.each
  end
end
