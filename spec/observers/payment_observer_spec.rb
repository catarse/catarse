require 'rails_helper'

RSpec.describe PaymentObserver do
  let(:contribution){ payment.contribution }
  let(:payment){ create(:payment, payment_method: 'should be updated', state: 'paid', paid_at: nil) }

  subject{ payment }

  describe "after_create" do
    context "when slip_payment is true" do
      let(:payment){ create(:payment, payment_method: 'BoletoBancario', state: 'paid') }
      it("should notify the contribution") do
        expect(ContributionNotification.where(template_name: 'payment_slip', user: contribution.user, contribution: contribution).count).to eq 1
      end
    end
  end

  describe "from_chargeback_to_paid" do
    let(:payment) { create(:payment, state: 'chargeback') }

    before do
      create(:user, email: CatarseSettings[:email_payments])
      payment.pay!
    end

    it "should notify backoffice when chargeback reverse" do
      expect(ContributionNotification.where(template_name: 'chargeback_reverse', contribution: contribution).count).to eq 1
    end
  end

  describe "after_update" do
    context "when is confirmed" do
      let(:payment) do
        payment = create(:payment, payment_method: 'BoletoBancario', state: 'pending')
        payment.pay!
        payment
      end
      it("should send confirm_contribution notification") do
        expect(ContributionNotification.where(template_name: 'confirm_contribution', user: contribution.user, contribution: contribution).count).to eq 1
      end
    end

    context "when is not yet confirmed" do
      let(:payment){ create(:payment, payment_method: 'BoletoBancario', state: 'pending') }
      it("should send confirm_contribution notification") do
        expect(ContributionNotification.where(template_name: 'confirm_contribution', user: contribution.user, contribution: contribution).count).to eq 0
      end
    end

    context "when paid_at already filled" do
      let(:payment) do
        payment = create(:payment, payment_method: 'BoletoBancario', state: 'pending', paid_at: 4.days.ago)
        payment.pay!
        payment
      end
      it("should not send confirm_contribution notification") do
        expect(ContributionNotification.where(template_name: 'confirm_contribution', user: contribution.user, contribution: contribution).count).to eq 0
      end

    end
  end

  describe "#from_paid_to_pending_refund" do
    before do
      payment.update_attributes(payment_method: payment_method)
      payment.notify_observers :from_paid_to_pending_refund
    end

    context "when contribution is made with credit card" do
      let(:payment_method) { 'CartaoDeCredito' }
      it { expect(ContributionNotification.where(template_name: 'contributions_project_unsucessful_slip', user_id: contribution.user_id).count).to eq(0) }
    end

    context "when contribution is made with slip" do
      let(:payment_method) { 'BoletoBancario' }
      it { expect(ContributionNotification.where(template_name: 'contributions_project_unsucessful_slip', user_id: contribution.user_id).count).to eq(1) }
    end
  end

  describe "#from_pending_refund_to_refunded" do
    before do
      payment.update_attributes(payment_method: payment_method)
      payment.notify_observers :from_pending_refund_to_refunded
    end

    context "when contribution is made with credit card" do
      let(:payment_method){ 'CartaoDeCredito' }

      it "should notify contributor about refund" do
        expect(ContributionNotification.where(template_name: 'refund_completed_credit_card', user_id: contribution.user.id).count).to eq 1
      end
    end

    context "when contribution is made with boleto" do
      let(:payment_method){ 'BoletoBancario' }

      it "should notify contributor about refund" do
        expect(ContributionNotification.where(template_name: 'refund_completed_slip', user_id: contribution.user.id).count).to eq 1
      end
    end
  end

  describe '#from_pending_refund_to_paid' do
    let(:admin){ create(:user) }
    before do
      allow(payment).to receive(:can_do_refund?).and_return(true)
      expect(payment).to_not receive(:direct_refund)
      payment.notify_observers :from_pending_refund_to_paid
    end

    context "when refund is invalid" do
      it "should send invalid refund notification" do
        expect(ContributionNotification.where(template_name: 'invalid_refund', user_id: payment.user.id).count).to eq 1
      end
    end
  end

  describe '#from_paid_to_refused' do
    before do
      CatarseSettings[:email_payments] = 'finan@c.me'
      @admin = create(:user, email: CatarseSettings[:email_payments])
    end

    context "when payment is confirmed and change to canceled" do
      before do
        payment.refuse!
      end

      it "should notify admin and contributor" do
        expect(ContributionNotification.where(template_name: 'contribution_canceled', user: contribution.user, contribution: contribution).count).to eq 1
        expect(ContributionNotification.where(template_name: 'contribution_canceled_after_confirmed', user: @admin, contribution: contribution).count).to eq 1
      end
    end
  end
end
