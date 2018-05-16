# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ContributionsController, type: :controller do
  subject { response }
  let(:admin) { create(:user, admin: true) }
  let(:current_user) { admin }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe 'POST batch_chargeback' do
    let!(:confirmed_contribution) { create(:confirmed_contribution) }
    let!(:payment) do
      _p = confirmed_contribution.payments.last
      _p.gateway_id = _p.id
      _p.save
      _p
    end

    let!(:confirmed_contribution_2) { create(:confirmed_contribution) }
    let!(:payment_2) do
      _p = confirmed_contribution_2.payments.last
      _p.gateway_id = _p.id
      _p.save
      _p
    end

    let!(:pending_contribution) { create(:pending_contribution) }
    let!(:payment_3) do
      _p = pending_contribution.payments.last
      _p.gateway_id = _p.id
      _p.save
      _p
    end


    context 'when not logged' do
      let(:current_user) { nil }
      before do
        allow(controller).to receive(:current_user).and_return(current_user)
        post :batch_chargeback, gateway_payment_ids: [payment.gateway_id, payment_2.gateway_id, payment_3.gateway_id], locale: :pt
      end

      it "should be redirect" do
        expect(response.code.to_i).to eq(302)
      end
    end

    context 'when logged without admin' do
      let(:current_user) { create(:user, admin: false) }
      before do
        allow(controller).to receive(:current_user).and_return(current_user)
        post :batch_chargeback, gateway_payment_ids: [payment.gateway_id, payment_2.gateway_id, payment_3.gateway_id], locale: :pt
      end

      it "should be redirect" do
        expect(response.code.to_i).to eq(302)
      end
    end

    context 'when admin logged' do
      let(:current_user) { create(:user, admin: true) }
      before do
        allow(controller).to receive(:current_user).and_return(current_user)
        post :batch_chargeback, gateway_payment_ids: [payment.gateway_id, payment_2.gateway_id, payment_3.gateway_id], locale: :pt
      end

      it "should be redirect" do
        expect(response.code.to_i).to eq(302)
      end
    end

    context 'when admin logged with balance role' do
      before do
        allow_any_instance_of(Project).to receive(:successful_pledged_transaction).and_return({id: 'mock'})
        current_user.admin_roles.create(role_label: 'balance')
        post :batch_chargeback, gateway_payment_ids: [payment.gateway_id, payment_2.gateway_id, payment_3.gateway_id], locale: :pt
      end

      it "should be successful" do
        expect(response.code.to_i).to eq(200)
      end

      it 'should chargeback and generate balance for valid chargeback subscriptions' do
        payment.reload
        payment_2.reload
        payment_3.reload

        expect(payment.chargeback?).to eq(true)
        expect(confirmed_contribution.chargedback_on_balance?).to eq(true)
        expect(payment_2.chargeback?).to eq(true)
        expect(confirmed_contribution_2.chargedback_on_balance?).to eq(true)
        expect(payment_3.chargeback?).to eq(false)
        expect(pending_contribution.chargedback_on_balance?).to eq(false)

      end
    end
  end

end
