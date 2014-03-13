require 'spec_helper'

describe Contribution::PaymentEngineHandler do
  let(:engine){ { name: 'moip', review_path: ->(contribution){ "/#{contribution}" }, locale: 'en' } }
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

  describe "#can_do_refund?" do
    subject { contribution.can_do_refund? }

    context "when contribution has a payment engine with direct refund enabled" do
      before do
        PaymentEngines.register(engine.merge!({ can_do_refund?: true }))
        contribution.stub(:direct_refund).and_return(true)
      end

      it { should be_true }
    end

    context "when contribution has a payment engine without direct refund enabled" do
      before do
        PaymentEngines.register(engine)
      end

      it { should be_false }
    end
  end

  describe "direct_refund" do
    subject { contribution.direct_refund }

    context "when contribution has a payment engine with direct refund enabled" do
      before do
        PaymentEngines.register(engine.merge!({ direct_refund: ->(contribution) { true } }))
      end

      it { should be_true }
    end

    context "when contribution has a payment engine without direct refund enabled" do
      before do
        PaymentEngines.register(engine)
      end

      it { should be_false }
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
