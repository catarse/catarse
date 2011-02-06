require 'spec_helper'

describe ProjectsController do

  it "should confirm backer in moip payment" do
    backer = Factory(:backer, :confirmed => false)
    post :moip, {:id_transacao => backer.id, :status_pagamento => '1', :valor => backer.moip_value}
    response.should be_successful
    backer.reload.confirmed.should be_true 
  end
  it "should not confirm in case of error in moip payment" do
    backer = Factory(:backer, :confirmed => false)
    post :moip, {:id_transacao => -1, :status_pagamento => '1', :valor => backer.moip_value}
    response.should_not be_successful
    backer.reload.confirmed.should_not be_true
  end
end
