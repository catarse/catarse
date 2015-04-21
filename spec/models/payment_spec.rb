require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:payment){ create(:payment) }

  describe "associations" do
    it{ should belong_to :contribution }
    it{ should have_many :payment_notifications }
  end

  describe "validations" do
    it{ should validate_presence_of :state }
    it{ should validate_presence_of :gateway }
    it{ should validate_presence_of :payment_method }
    it{ should validate_presence_of :value }
    it{ should validate_presence_of :installments }
  end

  describe ".can_delete" do
    subject { Payment.can_delete }

    before do
      @payment = create(:payment, state: 'pending', created_at: Time.now - 8.days)
      create(:payment, state: 'pending')
      create(:payment, state: 'paid', created_at: Time.now - 1.week)
    end
    it{ is_expected.to eq [@payment] }
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

  describe "#is_credit_card?" do
    subject{ payment.is_credit_card? }

    context "when payment_method is credit_card" do
      let(:payment){ build(:payment, payment_method: 'CartaoDeCredito') }
      it{ is_expected.to eq true }
    end

    context "when payment_method is anything but credit_card" do
      let(:payment){ build(:payment, payment_method: 'BoletoBancario') }
      it{ is_expected.to eq false }
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

  describe "#notification_template_for_failed_project" do
    subject { payment.notification_template_for_failed_project }

    context "when the method is credit card" do
      let(:payment){ build(:payment, payment_method: 'CartaoDeCredito') }
      it { is_expected.to eq(:contribution_project_unsuccessful_credit_card) }
    end

    context "when the method is payment slip" do
      let(:payment){ build(:payment, payment_method: 'BoletoBancario') }
      it { is_expected.to eq(:contribution_project_unsuccessful_slip) }
    end
  end

end
