# frozen_string_literal: true

require 'spec_helper'

describe CatarsePagarme::VerifyPagarmeWorker do
  let(:payment) { create(:contribution).payments.last }
  let(:fake_transaction) do
    {
      "object"=>"transaction", "status"=>"paid", "refuse_reason"=>nil, "id"=>9999,
      "status_reason"=>"acquirer", "acquirer_name" => 'stone', "tid" => "123123", "acquirer_response_code"=>"0000",
      "payment_method"=>"credit_card", "antifraud_score"=>nil, "boleto_url"=>nil, "boleto_barcode"=>nil, "boleto_expiration_date"=>nil,
      "metadata"=>{
        "key"=> payment.key,
        "contribution_id"=>"21313"}
    }
  end

  before do
    allow_any_instance_of(CatarsePagarme::VerifyPagarmeWorker).to receive(:find_source_by_key).and_return(fake_transaction)
  end

  context "When find a valid payment and source" do
    before do
      #allow(PaymentEngines).to receive(:find_payment).and_return(payment)
      allow_any_instance_of(CatarsePagarme::PaymentDelegator).to receive(:update_transaction)
      allow_any_instance_of(CatarsePagarme::PaymentDelegator).to receive(:change_status_by_transaction)

      expect_any_instance_of(Payment).to receive(:update).with({gateway_id: fake_transaction["id"]})
      expect_any_instance_of(CatarsePagarme::PaymentDelegator).to receive(:update_transaction)
      expect_any_instance_of(CatarsePagarme::PaymentDelegator).to receive(:change_status_by_transaction).with(fake_transaction["status"])
    end

    it "should satisfy expectations" do
      CatarsePagarme::VerifyPagarmeWorker.perform_async(payment.key)
    end
  end

  context "When source is not found" do
    before do
      allow_any_instance_of(CatarsePagarme::VerifyPagarmeWorker).to receive(:find_source_by_key).and_return(nil)
    end

    it "should raise an error" do
      expect {
        CatarsePagarme::VerifyPagarmeWorker.perform_async(payment.key)
      }.to raise_error("source not found")
    end
  end

  context "When source keys not match" do
    before do
      allow_any_instance_of(CatarsePagarme::VerifyPagarmeWorker).to receive(:find_source_by_key).and_return(fake_transaction["metadata"].update({"key" => "AFSGSD"}))
    end

    it "should raise an error" do
      expect {
        CatarsePagarme::VerifyPagarmeWorker.perform_async(payment.key)
      }.to raise_error("source not found")
    end
  end

  context "When payment is not found" do
    it "should raise an error" do
      expect {
        CatarsePagarme::VerifyPagarmeWorker.perform_async('INVALID KEY')
      }.to raise_error("payment not found")
    end
  end
end
