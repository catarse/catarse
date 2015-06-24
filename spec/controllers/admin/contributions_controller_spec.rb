require 'rails_helper'

RSpec.describe Admin::ContributionsController, type: :controller do
  subject{ response }
  let(:admin) { create(:user, admin: true) }
  let(:payment) { contribution.payments.first }
  let(:contribution) { create(:pending_contribution) }
  let(:current_user){ admin }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe 'PUT gateway_refund' do
    let(:payment) { create(:payment, state: 'paid') }

    before do
      expect(DirectRefundWorker).to receive(:perform_async).with(payment.id)
      put :gateway_refund, id: payment.id, locale: :pt
    end

    it "should call direct refund on payment pagarme_delegator" do
      is_expected.to redirect_to admin_contributions_path
    end
  end

  describe 'PUT pay' do
    subject { payment.paid? }

    before do
      put :pay, id: payment.id, locale: :pt
    end

    it do
      payment.reload
      is_expected.to eq(true)
    end
  end

  describe 'PUT trash' do
    before do
      allow(controller).to receive(:current_user).and_return(admin)
      put :trash, id: payment.id, locale: :pt
      payment.reload
    end

    it "should delete the contribution and redirect back" do
      expect(payment.deleted?).to be(true)
      is_expected.to be_redirect
    end
  end

  describe 'PUT refund' do
    let(:contribution) { create(:confirmed_contribution) }

    before do
      put :refund, id: payment.id, locale: :pt
      payment.reload
    end

    it "should refund the contribution and redirect back" do
      expect(payment.refunded?).to eq(true)
      is_expected.to be_redirect
    end
  end

  describe 'PUT request_refund' do
    let(:contribution) { create(:confirmed_contribution) }

    before do
      allow(payment).to receive(:direct_refund).and_return(true)
      put :request_refund, id: payment.id, locale: :pt
      payment.reload
    end

    it "should request_refund on contribution and redirect back" do
      expect(payment.pending_refund?).to eq(true)
      is_expected.to be_redirect
    end
  end

  describe "GET index" do
    context "when I'm not logged in" do
      let(:current_user){ nil }
      before do
        get :index, locale: :pt
      end
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when I'm logged as admin" do
      before do
        get :index, locale: :pt
      end
      its(:status){ should == 200 }
    end
  end

  describe '.collection' do
    let(:contribution) { create(:confirmed_contribution, payer_email: 'foo@foo.com') }
    context "when there is a match" do
      before do
        contribution
        get :index, locale: :pt, user_email_contains: 'foo@foo.com'
      end
      it{ expect(assigns(:contributions).count).to eq(1) }
    end

    context "when there is no match" do
      before do
        contribution
        get :index, locale: :pt, user_email_contains: '2foo@foo.com'
      end
      it{ expect(assigns(:contributions)).to eq([]) }
    end
  end
end
