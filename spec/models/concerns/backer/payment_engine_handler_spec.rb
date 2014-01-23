require 'spec_helper'

describe Contribution::PaymentEngineHandler do
  let(:engine){ { name: 'moip', review_path: ->(contribution){ "/#{contribution}" }, locale: 'en', refund_path: ->(contribution){ "/refund/#{contribution}" } } }
  let(:contribution){ create(:contribution, payment_method: 'MoIP') }

  before do
    PaymentEngines.clear
    engine
  end

  describe "#payment_engine" do
    subject { contribution.payment_engine }

    context "when contribution has a payment engine" do
      before { PaymentEngines.register engine }

      it { should eq(engine) }
    end

    context "when contribution don't have a payment engine" do
      it { should eq(nil) }
    end
  end

  describe "#refund_path" do
    subject { contribution.refund_path }

    context "when contribution has a payment engine" do
      before { PaymentEngines.register engine }

      it { should eq(engine[:refund_path].call(contribution)) }
    end

    context "when contribution don't have a payment engine" do
      it { should eq(nil) }
    end
  end

  describe "#review_path" do
    subject { contribution.review_path }

    context "when contribution has a payment engine" do
      before { PaymentEngines.register engine }

      it { should eq(engine[:review_path].call(contribution)) }
    end

    context "when contribution don't have a payment engine" do
      it { should eq(nil) }
    end
  end
end
