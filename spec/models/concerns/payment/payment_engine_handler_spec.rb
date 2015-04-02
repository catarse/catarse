require 'rails_helper'

RSpec.describe Payment::PaymentEngineHandler, type: :model do
  let(:payment){ create(:payment, gateway: 'MoIP') }
  let(:moip_engine) { double }

  before do
    allow_any_instance_of(Payment).to receive(:payment_engine).and_call_original
    PaymentEngines.clear

    allow(moip_engine).to receive(:name).and_return('MoIP')
    allow(moip_engine).to receive(:review_path).and_return("/#{payment}")
    allow(moip_engine).to receive(:locale).and_return('pt')
    allow(moip_engine).to receive(:can_do_refund?).and_return(false)
    allow(moip_engine).to receive(:direct_refund).and_return(false)

  end

  let(:engine){ moip_engine }

  describe "#payment_engine" do
    subject { payment.payment_engine }

    context "when payment has a payment engine" do
      before { PaymentEngines.register engine }

      it { is_expected.to eq(engine) }
    end

    context "when payment don't have a payment engine" do
      it { is_expected.to be_a_kind_of(PaymentEngines::Interface) }
    end
  end

  describe "#can_do_refund?" do
    subject { payment.can_do_refund? }

    context "when payment has a payment engine with direct refund enabled" do
      before do
        allow(moip_engine).to receive(:can_do_refund?).and_return(true)
        PaymentEngines.register(engine)
      end

      it { is_expected.to eq(true) }
    end

    context "when payment has a payment engine without direct refund enabled" do
      before do
        PaymentEngines.register(engine)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe "direct_refund" do
    subject { payment.direct_refund }

    context "when payment has a payment engine with direct refund enabled" do
      before do
        allow(moip_engine).to receive(:can_do_refund?).and_return(true)
        allow(moip_engine).to receive(:direct_refund).and_return(true)
        PaymentEngines.register(engine)
      end

      it { is_expected.to eq(true) }
    end

    context "when payment has a payment engine without direct refund enabled" do
      before do
        PaymentEngines.register(engine)
      end

      it { is_expected.to eq(false) }
    end
  end

  describe "#review_path" do
    subject { payment.review_path }

    context "when payment has a payment engine" do
      before do
        allow(payment).to receive(:payment_engine).and_return(engine)
        PaymentEngines.register engine
      end

      it { is_expected.to eq(engine.review_path(payment)) }
    end

    context "when payment don't have a payment engine" do
      it { is_expected.to eq(nil) }
    end
  end

end
