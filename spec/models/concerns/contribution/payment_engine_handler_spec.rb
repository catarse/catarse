require 'spec_helper'

describe Contribution::PaymentEngineHandler do
  let(:contribution){ create(:contribution, payment_method: 'MoIP') }
  let(:moip_engine) { double }

  before do
    Contribution.any_instance.unstub(:payment_engine)
    PaymentEngines.clear

    moip_engine.stub(:name).and_return('MoIP')
    moip_engine.stub(:review_path).and_return("/#{contribution}")
    moip_engine.stub(:locale).and_return('pt')
    moip_engine.stub(:can_do_refund?).and_return(false)
    moip_engine.stub(:direct_refund).and_return(false)

  end

  let(:engine){ moip_engine }

  describe "#payment_engine" do
    subject { contribution.payment_engine }

    context "when contribution has a payment engine" do
      before { PaymentEngines.register engine }

      it { should eq(engine) }
    end

    context "when contribution don't have a payment engine" do
      it { should be_a_kind_of(PaymentEngines::Interface) }
    end
  end

  describe "#can_do_refund?" do
    subject { contribution.can_do_refund? }

    context "when contribution has a payment engine with direct refund enabled" do
      before do
        moip_engine.stub(:can_do_refund?).and_return(true)
        PaymentEngines.register(engine)
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
        moip_engine.stub(:can_do_refund?).and_return(true)
        moip_engine.stub(:direct_refund).and_return(true)
        PaymentEngines.register(engine)
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
      before do
        contribution.stub(:payment_engine).and_return(engine)
        PaymentEngines.register engine
      end

      it { should eq(engine.review_path(contribution)) }
    end

    context "when contribution don't have a payment engine" do
      it { should eq(nil) }
    end
  end
end
