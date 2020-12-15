# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BalanceTransactionsController, type: :controller do
  subject { response }
  let(:admin) { create(:user, admin: true) }
  let(:current_user) { admin }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'POST transfer_balance' do
    let(:from_user) { create(:user) }
    let(:to_user) { create(:user) }
    let(:amount) { rand(1...1000) }

    context 'when user has admin roles' do
      before { current_user.admin_roles.create!(role_label: 'balance') }

      context 'when successfully transferred' do
        before do
          create(:balance_transaction, user: from_user, amount: 1000, event_name: 'subscription_payment')
          post :transfer_balance, params: { balance_transaction: { from_user_id: from_user.id, to_user_id: to_user.id, amount: amount } }
        end

        it 'transfers the amount to receiver' do
          expect(to_user.total_balance).to eq(amount)
        end

        it 'returns `created` http response' do
          expect(response).to have_http_status(:created)
        end

        it 'returns success message' do
          expect(response.body).to include(I18n.t("admin.balance_transactions.transfer_success"))
        end
      end

      context 'when an error occurs' do
        before { post :transfer_balance, params: { balance_transaction: { from_user_id: from_user.id, to_user_id: to_user.id, amount: amount } } }

        it 'doesn`t transfer the amount to receiver' do
          expect(to_user.total_balance).to eq(0)
        end

        it 'returns `unprocessable_entity` http response' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns an error message' do
          expect(response.body).to include("error")
        end
      end
    end

    context 'when user has not admin roles' do
      before { post :transfer_balance, params: { balance_transaction: { from_user_id: from_user.id, to_user_id: to_user.id, amount: amount } } }

      it 'should be redirect' do
        expect(response.code.to_i).to eq(302)
      end

      it 'doesn`t transfer the amount to receiver' do
        expect(to_user.total_balance).to eq(0)
      end
    end
  end

end
