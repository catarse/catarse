require 'spec_helper'

describe PaymentNotification do
  describe "Associations" do
    it{ should belong_to :contribution }
  end

  describe "#extra_data" do
    let(:test_hash){{"test_hash" => 1}}
    before do
      @p = PaymentNotification.new(contribution_id: FactoryGirl.create(:contribution).id, extra_data: test_hash)
      @p.save!
    end
    subject{ @p.extra_data }
    it{ should == test_hash }
  end
end
