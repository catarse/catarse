require 'spec_helper'
describe PaymentStreamController do
  it "should confirm backer in moip payment" do
    backer = Factory(:backer, :confirmed => false)
    post :moip, post_moip_params.merge!({:id_transacao => backer.key, :status_pagamento => '1', :valor => backer.moip_value})
    response.should be_successful
    backer.reload.confirmed.should be_true
  end
  it "should not confirm in case of error in moip payment" do
    backer = Factory(:backer, :confirmed => false)
    post :moip, post_moip_params.merge!({:id_transacao => -1, :status_pagamento => '1', :valor => backer.moip_value})
    response.should_not be_successful
    backer.reload.confirmed.should_not be_true
  end
  it "should return 422 when moip params is empty" do
    post :moip, {}
    response.should_not be_successful
    response.code.should == '422'
  end
end
