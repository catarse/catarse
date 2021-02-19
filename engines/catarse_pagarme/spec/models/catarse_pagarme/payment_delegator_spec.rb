# frozen_string_literal: true

require 'spec_helper'

describe CatarsePagarme::PaymentDelegator do
  let(:contribution) { create(:contribution, value: 10) }
  let(:payment) { contribution.payments.first }
  let(:delegator) { payment.pagarme_delegator }
  let(:interest_rate) { 0 }
  let(:fake_transaction) { double("fake transaction", id: payment.gateway_id, card_brand: 'visa', acquirer_name: 'stone', tid: '404040404', installments: 2) }

  before do
    allow(CatarsePagarme).to receive(:configuration).and_return(double('fake config', {
      slip_tax: 2.00,
      credit_card_tax: 0.01,
      pagarme_tax: 0.0063,
      cielo_tax: 0.038,
      stone_tax: 0.0307,
      antifraud_tax: 0.39,
      stone_installment_tax: 0.0307,
      credit_card_cents_fee: 0.39,
      api_key: '',
      interest_rate: interest_rate
    }))
    allow(delegator).to receive(:transaction).and_return(fake_transaction)
  end

  describe "instance of CatarsePagarme::paymentDelegator" do
    it { expect(delegator).to be_a CatarsePagarme::PaymentDelegator }
  end

  describe "#value_for_transaction" do
    subject { delegator.value_for_transaction }

    it "should convert payment value to pagarme value format" do
      expect(subject).to eq(1000)
    end
  end

  describe "#value_with_installment_tax" do
    let(:installment) { 5 }
    let(:interest_rate) { 1.8 }

    subject { delegator.value_with_installment_tax(installment)}

    it "should return the payment value with installments tax" do
      expect(subject).to eq(1090)
    end
  end

  describe "#get_fee" do
    context 'when choice is credit card and acquirer_name is nil' do
      let(:payment) { create(:payment, value: 10, payment_method: CatarsePagarme::PaymentType::CREDIT_CARD, gateway_data: {acquirer_name: nil}) }
      subject { delegator.get_fee }
      it { expect(subject).to eq(nil) }
    end

    context 'when choice is slip' do
      let(:payment) { create(:payment, value: 10, payment_method: CatarsePagarme::PaymentType::SLIP, gateway_data: {acquirer_name: nil}) }
      subject { delegator.get_fee }
      it { expect(subject).to eq(2.00) }
    end

    context 'when choice is international credit card' do
      let(:payment) { create(:payment, value: 10, payment_method: CatarsePagarme::PaymentType::CREDIT_CARD, gateway_data: {acquirer_name: 'stone', card_brand: 'visa'}, installments: 1) }
      before do
        allow(payment.contribution).to receive(:international?).and_return(true)
      end
      subject { delegator.get_fee }
      it { expect(subject).to eq(0.76) }
    end

    context 'when choice is national credit card' do
      let(:payment) { create(:payment, value: 10, payment_method: CatarsePagarme::PaymentType::CREDIT_CARD, gateway_data: {acquirer_name: 'stone', card_brand: 'visa'}, installments: 1) }
      before do
        allow(payment.contribution).to receive(:international?).and_return(false)
      end
      subject { delegator.get_fee }
      it { expect(subject).to eq(1.15) }
    end
  end

  describe "#get_installments" do
    before do
      allow(delegator).to receive(:value_for_transaction).and_return(10000)
    end
    subject { delegator.get_installments }

    it { expect(subject['installments'].size).to eq(12) }
    it { expect(subject['installments']['2']['installment_amount']).to eq(5000) }
  end

  describe "#fill_acquirer_data" do
    let(:payment) { create(:payment, gateway_data: nil) }

    before do
      delegator.fill_acquirer_data
    end

    it "should fill data about credit card acquirer" do
      expect(payment.gateway_data['acquirer_name']).to eq fake_transaction.acquirer_name
      expect(payment.gateway_data['acquirer_tid']).to eq fake_transaction.tid
      expect(payment.gateway_data['card_brand']).to eq fake_transaction.card_brand
    end
  end

  describe "#update_transaction" do
    before do
      expect(delegator).to receive(:fill_acquirer_data).and_call_original
      delegator.update_transaction
    end

    it "should update installment value" do
      expect(payment.installment_value).to eq (delegator.value_for_installment / 100.0).to_f
    end

    it "should update fee" do
      expect(payment.gateway_fee).to eq delegator.get_fee
    end
  end

  describe "#transaction" do
    before do
      delegator.unstub(:transaction)#.and_return(fake_transaction)
      allow(PagarMe::Transaction).to receive(:find_by_id).and_return(fake_transaction)
    end

    context "when payment.gateway id is null" do
      before do
        allow(payment).to receive(:gateway_id).and_return(nil)
      end

      it "should be nil" do
        expect(delegator.transaction).to eq(nil)
      end
    end

    context "when transaction.id dont match with gateway_id" do
      before do
        allow(fake_transaction).to receive(:id).and_return("123")
      end

      it "expect to raises an error" do
        expect {
          delegator.transaction
        }.to raise_error("transaction gateway not match 123 != 1.2.3")
      end
    end

    context "when have correct transaction" do
      it "should return the transaction object" do
        expect(delegator.transaction).to eq(fake_transaction)
      end
    end
  end

  describe "#transfer_funds" do
    let(:transfer_mock) { double(create: true, id: "123", to_json: {id: '123'}.to_json) }
    before do
      allow(PagarMe::Transfer).to receive(:new).and_return(transfer_mock)
      create(:bank_account, user: payment.user, bank: create(:bank, code: '237'))
    end

    it do
      transfer = delegator.transfer_funds

      expect(payment.payment_transfers.count).to eq(1)
      expect(transfer.payment).to eq(payment)
      expect(transfer.user).to eq(payment.user)
      expect(transfer.transfer_id).to eq(transfer.transfer_data["id"])
    end
  end


  describe "#change_status_by_transaction" do
    %w(paid).each do |status|
      context "when status is #{status}" do
        context "when payment is refunded" do
          before do
            payment.stub(:paid?).and_return(false)
            payment.stub(:refunded?).and_return(true)
            payment.stub(:pending_refund?).and_return(false)
          end

          it { delegator.change_status_by_transaction(status) }
        end

        context "when payment is pending_refund" do
          before do
            payment.stub(:paid?).and_return(false)
            payment.stub(:refunded?).and_return(false)
            payment.stub(:pending_refund?).and_return(true)
          end

          it { delegator.change_status_by_transaction(status) }
        end

        context "and payment is already paid" do
          before do
            payment.stub(:paid?).and_return(true)
            payment.stub(:refunded?).and_return(false)
            payment.stub(:pending_refund?).and_return(false)
            expect(payment).to_not receive(:pay)
          end

          it { delegator.change_status_by_transaction(status) }
        end

        context "and payment is not paid" do
          before do
            payment.stub(:paid?).and_return(false)
            payment.stub(:refunded?).and_return(false)
            payment.stub(:pending_refund?).and_return(false)
            expect(payment).to receive(:pay)
          end

          it { delegator.change_status_by_transaction(status) }
        end
      end
    end

    context "when status is pending_review" do
      it 'notifies pending reviews' do
        expect(payment).to receive(:notify_about_pending_review)

        delegator.change_status_by_transaction('pending_review')
      end

      it 'should keep state in current_status' do
        expect {
          delegator.change_status_by_transaction('pending_review')
        }.to_not change(payment, :state)
      end
    end

    context "when status is refunded" do
      context 'when payment state is pending' do
        before { payment.stub(:pending?).and_return(true) }

        it 'refuses payment' do
          expect(payment).to receive(:refuse)

          delegator.change_status_by_transaction('refunded')
        end
      end

      context 'when payment state isn`t pending' do
        before { payment.stub(:pending?).and_return(false) }

        context 'when payment state is refunded' do
          before { payment.stub(:refunded?).and_return(true) }

          it 'doesn`t refund payment again' do
            expect(payment).to_not receive(:refund)

            delegator.change_status_by_transaction('refunded')
          end
        end

        context 'when payment state isn`t refunded' do
          before { payment.stub(:refunded?).and_return(false) }

          it 'refunds payment' do
            expect(payment).to receive(:refund)

            delegator.change_status_by_transaction('refunded')
          end
        end
      end
    end

    context "when status is refused" do
      context "and payment is already canceled" do
        before do
          payment.stub(:refused?).and_return(true)
          expect(payment).to_not receive(:refuse)
        end

        it { delegator.change_status_by_transaction('refused') }
      end

      context "and payment is not refused" do
        before do
          payment.stub(:refused?).and_return(false)
          expect(payment).to receive(:refuse)
        end

        it { delegator.change_status_by_transaction('refused') }
      end
    end

  end
end
