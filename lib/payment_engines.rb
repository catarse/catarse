class PaymentEngines
  @@engines = []

  def self.find_engine name
    # if name is nil we should return nil
    name && engines.find do |engine|
      engine.name.downcase == name.downcase
    end
  end

  def self.register options
    # This method is deprecated. Engines are now dynamicaly found.
  end

  def self.clear
    @@engines.clear
  end

  def self.engines
    ::Rails::Engine.subclasses.map do |e| 
      engine_namespace = e.instance.railtie_namespace
      if engine_namespace && engine_namespace.constants.include?(:PaymentEngine)
        engine_namespace.const_get(:PaymentEngine).new
      end
    end.compact 
  end

  def self.create_payment_notification attributes
    PaymentNotification.create! attributes
  end

  def self.configuration
    CatarseSettings
  end

  def self.find_contribution id
    Contribution.find(id)
  end

  def self.find_payment filter
    Payment.where(filter).first
  end

  def self.new_payment attributes={}
    Payment.new attributes
  end
end
