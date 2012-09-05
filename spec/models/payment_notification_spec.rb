require 'spec_helper'

describe PaymentNotification do
  describe "#extra_data" do
    let(:test_hash){{"test_hash" => 1}}
    before do
      @p = PaymentNotification.new(backer_id: Factory(:backer).id, status: 'pending', extra_data: test_hash)
      @p.save!
    end
    subject{ @p.extra_data }
    it{ should == test_hash }
  end

  describe "#save!" do
    before do
      @backer = create(:backer, confirmed: false, refunded: false)
      @payment = PaymentNotification.new backer: @backer
    end

    context "when status is confirmed" do
      before do
        @payment.status = 'confirmed'
        @payment.save!
      end

      it "should not confirm the backer" do
        @backer.confirmed?.should be_true
      end

      it "should refund the backer" do
        @backer.refunded?.should be_false
      end
    end

    context "when status is refunded" do
      before do
        @payment.status = 'refunded'
        @payment.save!
      end

      it "should not confirm the backer" do
        @backer.confirmed?.should be_false
      end

      it "should refund the backer" do
        @backer.refunded?.should be_true
      end
    end
  end
end
