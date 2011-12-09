require 'spec_helper'
PaypalApi.configure do |config|
  config.username   = 'tastie'
  config.password   = 'passwd'
  config.signature  = 'sing'
end

describe PaypalApi do
  context 'configuration' do
    it 'should return the users params' do
      PaypalApi.username.should == 'tastie'
      PaypalApi.password.should == 'passwd'
      PaypalApi.signature.should == 'sing'
    end

    it { PaypalApi.endpoint.should == 'https://api-3t.paypal.com/nvp' }
  end

  it 'build API url' do
    PaypalApi.build_url(1234).should == 'https://api-3t.paypal.com/nvp?METHOD=GetTransactionDetails&TRANSACTIONID=1234&USER=tastie&PWD=passwd&SIGNATURE=sing&VERSION=78.0'
  end

  context 'find some element value in paypal response' do
    it 'find fee amount' do
      PaypalApi.find_element_value("FEEAMT", paypal_transaction_details_fake_response).
        should == '5.72'
    end
  end
end