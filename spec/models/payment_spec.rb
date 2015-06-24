require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:payment){ create(:payment) }

  describe "associations" do
    it{ should belong_to :contribution }
    it{ should have_many :payment_notifications }
  end

  describe "validations" do
    subject { build(:payment) }
    it{ should validate_presence_of :state }
    it{ should validate_presence_of :gateway }
    it{ should validate_presence_of :payment_method }
    #NOTE: now that we need to use build, value never wil be nil
    # it{ should validate_presence_of :value }
    it{ should validate_presence_of :installments }
  end

  describe "#project_should_be_online" do
    subject{ payment }
    context "when project is draft" do
      let(:project) { create(:project, state: 'online')}
      let(:payment){ build(:payment,contribution: create(:contribution, project: project)) }
      before do
        payment
        project.update_column(:state, 'draft')
      end
      it{ is_expected.not_to be_valid }
    end
    context "when project is waiting_funds" do
      let(:project) { create(:project, state: 'online')}
      let(:payment){ build(:payment,contribution: create(:contribution, project: project)) }
      before do
        payment
        project.update_column(:state, 'waiting_funds')
      end
      it{ is_expected.not_to be_valid }
    end
    context "when project is successful" do
      let(:project) { create(:project, state: 'online')}
      let(:payment){ build(:payment,contribution: create(:contribution, project: project)) }
      before do
        payment
        project.update_column(:state, 'successful')
      end
      it{ is_expected.not_to be_valid }
    end
    context "when project is online" do
      let(:project) { create(:project, state: 'online')}
      let(:payment){ build(:payment,contribution: create(:contribution, project: project)) }
      it{ is_expected.to be_valid }
    end
    context "when project is failed" do
      let(:project) { create(:project, state: 'online')}
      let(:contribution){ build(:contribution, project: unfinished_project) }
      before do
        payment
        project.update_column(:state, 'failed')
      end
      it{ is_expected.to be_valid }
    end
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

  describe "#move_to_trash" do
    let(:payment) { create(:payment, state: 'pending') }

    context "when transaction is not pending on gateway" do
      before do
        allow(payment).to receive(:current_transaction_state).and_return('paid')
        expect(payment).to_not receive(:trash)
        expect(payment).to receive(:change_status_from_transaction)
      end

      it { payment.move_to_trash }
    end

    context "when transaction is pending on gateway" do
      before do
        allow(payment).to receive(:current_transaction_state).and_return('waiting_payment')
        expect(payment).to receive(:trash)
        expect(payment).to_not receive(:change_status_from_transaction)
      end

      it { payment.move_to_trash }
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

    context "when the method is payment slip user has bank account" do
      let(:payment){ build(:payment, payment_method: 'BoletoBancario') }
      it { is_expected.to eq(:contribution_project_unsuccessful_slip) }
    end

    context "when the method is payment slip user has no bank account" do
      before do
        payment.user.bank_account = nil
      end
      let(:payment){ build(:payment, payment_method: 'BoletoBancario') }
      it { is_expected.to eq(:contribution_project_unsuccessful_slip_no_account) }
    end
  end

end
