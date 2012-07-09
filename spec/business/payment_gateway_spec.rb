require 'spec_helper'

describe PaymentGateway do
  subject do
    PaymentGateway.new({
      login: 'payment login',
      password: 'payment pass',
      signature: 'payment signature'
    })
  end
  before do
    ActiveMerchant::Billing::PaypalExpressGateway.any_instance.stubs(:details_for).returns('details_for')
  end
  its(:details_for){ should == 'details_for' }
  
end
