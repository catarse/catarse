# encoding: utf-8

require 'rails_helper'

RSpec.describe PaymentEngines do
  let(:contribution){ FactoryGirl.create(:contribution) }
  let(:payment){ FactoryGirl.create(:confirmed_contribution).payments.first }
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

  let(:engine){ paypal_engine }
  let(:engine_pt){ moip_engine }

  describe ".configuration" do
    subject{ PaymentEngines.configuration }
    it{ is_expected.to eq(CatarseSettings) }
  end

  describe ".create_payment_notification" do
    subject{ PaymentEngines.create_payment_notification({ contribution_id: contribution.id, extra_data: { test: true } }) }
    it{ is_expected.to eq(PaymentNotification.where(contribution_id: contribution.id).first) }
  end

  describe ".find_contribution" do
    subject{ PaymentEngines.find_contribution(contribution.id) }
    it{ is_expected.to eq(contribution) }
  end

  describe ".find_payment" do
    subject{ PaymentEngines.find_payment({ id: payment.id }) }
    it{ is_expected.to eq(payment) }
  end
end
