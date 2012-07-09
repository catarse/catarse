class PaymentGateway
  attr_accessor :gateway
  delegate :details_for, :to => :gateway

  def initialize options
    @gateway = ActiveMerchant::Billing::PaypalExpressGateway.new({
      login: options[:login],
      password: options[:password],
      signature: options[:signature]
    })
  end
end
