require 'rails_helper'

RSpec.describe DirectRefundWorker do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:confirmed_contribution) { create(:confirmed_contribution, project_id: project.id, user_id: user.id) }
  let(:payment) { confirmed_contribution.payments.first }
  let!(:contact_user) { create(:user, email: CatarseSettings[:email_contact])}

  before do
    Sidekiq::Testing.inline!
    allow(Payment).to receive(:find).with(payment.id).and_return(payment)
  end

  context "when job runs" do
    before do
      expect(payment.payment_engine).to receive(:direct_refund).and_return(true)
    end

    it "should call direct refund at payment engine" do
      DirectRefundWorker.perform_async(payment.id)
    end
  end

  context "when PagarMe error raises" do
    before do
      allow(payment.payment_engine).to receive(:direct_refund).and_raise(Exception, "Not found")
    end

    it "should create notification for backoffice" do
      DirectRefundWorker.perform_async(payment.id)
      expect(ContributionNotification.where(template_name: 'direct_refund_worker_error').count).to eq(1)
    end
  end
end

