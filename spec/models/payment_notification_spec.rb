require 'spec_helper'

describe PaymentNotification do
  describe "#extra_data" do
    let(:test_hash){{"test_hash" => 1}}
    before do
      @p = PaymentNotification.new(backer_id: Factory(:backer).id, extra_data: test_hash)
      @p.save!
    end
    subject{ @p.extra_data }
    it{ should == test_hash }
  end
end
