require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:payment){ create(:payment) }

  describe "associations" do
    it{ should belong_to :contribution }
  end

  describe "validations" do
    it{ should validate_presence_of :state }
    it{ should validate_presence_of :gateway }
    it{ should validate_presence_of :payment_method }
    it{ should validate_presence_of :value }
    it{ should validate_presence_of :installments }
    it{ should validate_presence_of :installment_value }
  end

  describe "#valid?" do
    subject{ payment.valid? }

    context "when payment value is equal than what was pledged" do
      let(:payment){ build(:payment, value: 10, contribution: create(:contribution, value: 10)) }
      it{ is_expected.to eq true }
    end

    context "when payment value is lower than what was pledged" do
      let(:payment){ build(:payment, value: 9, contribution: create(:contribution, value: 10)) }
      it{ is_expected.to eq false }
    end

    it "should set key" do
      expect(payment.key).to_not be_nil
    end
  end

  describe "#credits?" do
    subject{ payment.credits? }

    context "when the gateway is Credits" do
      let(:payment){ build(:payment, gateway: 'Credits') }
      it{ is_expected.to eq true }
    end

    context "when the gateway is anything but Credits" do
      let(:payment){ build(:payment, gateway: 'AnythingButCredits') }
      it{ is_expected.to eq false }
    end
  end

  describe "#slip_payment?" do
    subject{ payment.slip_payment? }

    context "when the method is payment slip" do
      let(:payment){ build(:payment, payment_method: 'BoletoBancario') }
      it{ is_expected.to eq true }
    end

    context "when the method is credit card" do
      let(:payment){ build(:payment, payment_method: 'CartaoDeCredito') }
      it{ is_expected.to eq false }
    end
  end
end
