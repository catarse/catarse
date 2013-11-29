require 'spec_helper'

describe Backer::PaymentEngineHandler do
  let(:engine){ { name: 'moip', review_path: ->(backer){ "/#{backer}" }, locale: 'en', refund_path: ->(backer){ "/refund/#{backer}" } } }
  let(:backer){ create(:backer) }

  before do
    PaymentEngines.clear
    engine
  end

  describe "#payment_engine" do
    subject { backer.payment_engine }

    context "when backer has a payment engine" do
      before { PaymentEngines.register engine }

      it { should eq(engine) }
    end

    context "when backer don't have a payment engine" do
      it { should eq(nil) }
    end
  end

  describe "#refund_path" do
    subject { backer.refund_path }

    context "when backer has a payment engine" do
      before { PaymentEngines.register engine }

      it { should eq(engine[:refund_path].call(backer)) }
    end

    context "when backer don't have a payment engine" do
      it { should eq(nil) }
    end
  end

  describe "#review_path" do
    subject { backer.review_path }

    context "when backer has a payment engine" do
      before { PaymentEngines.register engine }

      it { should eq(engine[:review_path].call(backer)) }
    end

    context "when backer don't have a payment engine" do
      it { should eq(nil) }
    end
  end
end
