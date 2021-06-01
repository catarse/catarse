# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SubscriptionPaymentsController, type: :controller do
  let(:admin) { create(:user, admin: true) }
  let(:current_user) { admin }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe 'POST refund_payment' do
    context 'when user has admin roles and succeed' do
      let(:payment_common_id) { SecureRandom.uuid }
      let(:subscription_payment) { SubscriptionPayment.new(id: payment_common_id) }

      before do
        current_user.admin_roles.create(role_label: 'refund_subscription')

        allow(SubscriptionPayment).to receive(:find).with(payment_common_id).and_return(subscription_payment)
        allow(subscription_payment).to receive(:refund).and_return(true)

        post :refund, params: { refund_payment: { payment_common_id: payment_common_id } }
      end

      it 'refunds subscription payment' do
        expect(subscription_payment).to receive(:refund)

        post :refund, params: { refund_payment: { payment_common_id: payment_common_id } }
      end

      it 'returns `created` http response' do
        expect(response).to have_http_status(:created)
      end

      it 'returns an success message' do
        expect(response.body).to include(I18n.t('admin.refund_subscriptions.refund_success'))
      end
    end

    context 'when user has admin roles and an error occurs' do
      before do
        current_user.admin_roles.create(role_label: 'refund_subscription')
        post :refund, params: { refund_payment: { payment_common_id: SecureRandom.uuid } }
      end

      it 'returns `unprocessable_entity` http response' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an error message' do
        expect(response.body).to include('error')
      end
    end

    context 'when user has not admin roles' do
      before { post :refund, params: { refund_payment: { payment_common_id: SecureRandom.uuid } } }

      it 'redirects' do
        expect(response.code.to_i).to eq(302)
      end
    end
  end
end
