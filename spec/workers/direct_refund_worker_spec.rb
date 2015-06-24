require 'rails_helper'

RSpec.describe DirectRefundWorker do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:confirmed_contribution) { create(:confirmed_contribution, project_id: project.id, user_id: user.id) }
  let(:payment) { confirmed_contribution.payments.first }

  before do
    Sidekiq::Testing.inline!
    allow(Payment).to receive(:find).with(payment.id).and_return(payment)
    expect(payment.payment_engine).to receive(:direct_refund)
  end

  it "should call direct refund at payment engine" do
    DirectRefundWorker.perform_async(payment.id)
  end
end

