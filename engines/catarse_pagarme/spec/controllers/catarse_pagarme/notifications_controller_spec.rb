require 'spec_helper'

describe CatarsePagarme::NotificationsController, type: :controller do
  let(:fake_transaction) { double("fake transaction", id: payment.gateway_id, card_brand: 'visa', acquirer_name: 'stone', tid: '404040404', installments: 2) }

  before do
    @routes = CatarsePagarme::Engine.routes
    allow(PagarMe::Postback).to receive(:validate_request_signature?).and_return(true)
    allow(PagarMe::Transaction).to receive(:find_by_id).and_return(fake_transaction)
  end

  let(:project) { create(:project, goal: 10_000, state: 'online') }
  let(:contribution) { create(:contribution, value: 10, project: project) }
  let(:payment) {
    p = contribution.payments.first
    p.update gateway_id: 'abcd'
    p
  }
  let(:credit_card) { create(:credit_card, subscription_id: '1542')}

  describe 'CREATE' do
    context "with invalid payment" do
      before do
        allow(PaymentEngines).to receive(:find_payment).and_return(nil)
        post :create, { locale: :pt, id: 'abcdfg'}
      end

      it "should not found the payment" do
        expect(response.code.to_i).to eq(400)
      end
    end

    context "with valid payment" do
      before do
        allow(PaymentEngines).to receive(:find_payment).and_return(payment)
        allow_any_instance_of(CatarsePagarme::NotificationsController).to receive(:valid_postback?).and_return(true)
        post :create, { locale: :pt, id: 'abcd'}
      end

      it "should save an extra_data into payment_notifications" do
        expect(payment.payment_notifications.size).to eq(1)
      end

      it "should return 200 status" do
        expect(response.code.to_i).to eq(200)
      end
    end
  end

end
