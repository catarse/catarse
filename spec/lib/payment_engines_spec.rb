# encoding: utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaymentEngines do
  let(:contribution) { create(:contribution) }
  let(:payment) { create(:confirmed_contribution).payments.first }
  let(:paypal_engine) { double }
  let(:moip_engine) { double }

  before do
    PaymentEngines.clear
    allow(paypal_engine).to receive(:name).and_return('PayPal')
    allow(paypal_engine).to receive(:review_path).with(contribution).and_return("/#{contribution}")
    allow(paypal_engine).to receive(:locale).and_return('en')

    allow(moip_engine).to receive(:name).and_return('MoIP')
    allow(moip_engine).to receive(:review_path).with(contribution).and_return("/#{contribution}")
    allow(moip_engine).to receive(:locale).and_return('pt')
  end

  let(:engine) { paypal_engine }
  let(:engine_pt) { moip_engine }

  describe '.configuration' do
    subject { PaymentEngines.configuration }
    it { is_expected.to eq(CatarseSettings) }
  end

  describe '.create_payment_notification' do
    subject { PaymentEngines.create_payment_notification({ contribution_id: contribution.id, extra_data: { test: true } }) }
    it { is_expected.to eq(PaymentNotification.where(contribution_id: contribution.id).first) }
  end

  describe '.find_contribution' do
    subject { PaymentEngines.find_contribution(contribution.id) }
    it { is_expected.to eq(contribution) }
  end

  describe '.find_payment' do
    subject { PaymentEngines.find_payment({ id: payment.id }) }
    it { is_expected.to eq(payment) }
  end

  describe '.was_credit_card_used_before?' do
    before do
      payment.update(
        state: 'paid',
        gateway: 'Pagarme',
        payment_method: 'CartaoDeCredito',
        gateway_data: { card: { id: 'some-id' } }
      )
    end

    context 'when there is a paid payment with given card_id and given user_id' do
      subject { described_class.was_credit_card_used_before?('some-id', payment.contribution.user.id) }
      it { is_expected.to be_truthy }
    end

    context 'when there isn`t a paid payment with given card_id' do
      subject { described_class.was_credit_card_used_before?('fake-id', payment.contribution.user.id) }
      it { is_expected.to be_falsey }
    end

    context 'when there isn`t a paid payment with given card_id but with different user_id' do
      subject { described_class.was_credit_card_used_before?('some-id', 'fake-user-id') }
      it { is_expected.to be_falsey }
    end
  end
end
