require 'rails_helper'

RSpec.describe Payment, type: :model do
  SLIP_EXPIRATION_WEEKDAYS = 2
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

  describe "#save" do
    let(:reward){ create(:reward, maximum_contributions: 1, project: project) }
    let(:contribution){ create(:contribution, reward: reward, project: reward.project) }
    let(:payment){ build(:payment, contribution: contribution) }

    context "when project is still open for payments" do
      let(:project){ create(:project) }

      # This validation is implemented in the database schema
      it "should not create when reward is sold_out" do
        # creates payment to let reward in sold_out state
        create(:payment, contribution: contribution, value: payment.value + 1)
        expect{ payment.save }.to raise_error(/Reward for contribution/)
      end
    end

    context "when project is expired" do
      let(:project){ create(:project, online_date: Time.current - 30.day, online_days: 1, expires_at: 2.days.ago, state: 'online') }

      before do
        payment.valid?
      end

      # This validation is implemented in the database schema
      it "should not create when project is past expires_at" do
        expect(payment.errors[:project]).to_not be_nil
      end
    end
  end

  describe "#is_unique_within_period" do
    subject{ payment }
    let(:contribution){ create(:contribution) }
    let(:payment){ build(:payment,contribution: contribution) }

    context "when is the first payment of the contribution" do
      it{ is_expected.to be_valid }
    end

    context "when we have a payment with same value and method within DUPLICATION_PERIOD" do
      let!(:first_payment){ create(:payment,contribution: contribution, payment_method: payment.payment_method, value: payment.value) }
      it{ is_expected.not_to be_valid }
    end
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

  describe "#slip_expired?" do
    subject { payment.slip_expired? }

    context "when slipt is past expiration date" do
      let(:payment){ create(:payment, state: 'pending', created_at: (SLIP_EXPIRATION_WEEKDAYS.weekdays_ago - 1.hour)) }
      it{ is_expected.to eq true }
    end

    context "when slip is not past expiration date" do
      let(:payment){ create(:payment, state: 'pending') }
      it{ is_expected.to eq false }
    end
  end

  describe "#waiting_payment?" do
    subject { payment.waiting_payment? }

    context "when payment is expired" do
      let(:payment){ create(:payment, state: 'pending', created_at: Time.now - 8.days) }
      it{ is_expected.to eq false }
    end

    context "when payment is not expired" do
      let(:payment){ create(:payment, state: 'pending') }
      it{ is_expected.to eq true }
    end
  end

  describe ".waiting_payment" do
    subject { Payment.waiting_payment }

    before do
      @payment = create(:payment, state: 'pending')
      create(:payment, state: 'pending', created_at: Time.now - 8.days)
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
