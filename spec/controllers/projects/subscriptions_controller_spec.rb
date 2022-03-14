# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::SubscriptionsController, type: :controller do
  let(:payment_common_id) { SecureRandom.uuid }
  let(:user) { create(:user) }
  let(:subscription_payment) do
    SubscriptionPayment.new(
      id: SecureRandom.uuid,
      project: create(:subscription_project, user: user),
      user: user,
      gateway_cached_data: {
        payables: {
          amount: Faker::Number.number(digits: 4),
          id: Faker::Number.number(digits: 4),
          payment_date: Time.zone.now,
          payment_method: 'boleto'
        }
      }
    )
  end

  describe 'Get /receipt' do
    before do
      allow(SubscriptionPayment).to receive(:find).with(payment_common_id).and_return(subscription_payment)
    end

    context 'when user is admin and subscriptionpayment is successful' do
      let(:admin) { create(:user, admin: true) }
      let(:current_user) { admin }

      before do
        allow(controller).to receive(:current_user).and_return(current_user)
        get :receipt, params: { payment_id: payment_common_id }
      end

      it 'returns success' do
        expect(response).to have_http_status(:ok)
      end

      it "renders 'subscription_receipt' template" do
        expect(response).to render_template('user_notifier/mailer/subscription_receipt')
      end
    end

    context 'when user is owner and subscriptionpayment is successful' do
      let(:current_user) { user }

      before do
        allow(controller).to receive(:current_user).and_return(current_user)
        get :receipt, params: { payment_id: payment_common_id }
      end

      it 'returns success' do
        expect(response).to have_http_status(:ok)
      end

      it "renders 'subscription_receipt' template" do
        expect(response).to render_template('user_notifier/mailer/subscription_receipt')
      end
    end

    context 'when user is not owner and subscriptionpayment is successful' do
      let(:current_user) { create(:user) }

      before do
        allow(controller).to receive(:current_user).and_return(current_user)
        get :receipt, params: { payment_id: payment_common_id }
      end

      it 'is redirect' do
        expect(response.code.to_i).to eq(302)
      end
    end
  end
end
