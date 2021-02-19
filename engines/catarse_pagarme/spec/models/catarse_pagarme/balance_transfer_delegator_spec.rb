# frozen_string_literal: true

require 'spec_helper'

describe CatarsePagarme::BalanceTransferDelegator do
  let(:project) { create(:project, state: 'successful') }
  let(:project_acc) { create(:project_account, project: project) }
  let(:bank) { create(:bank) }
  let!(:bank_account) { create(:bank_account, user: project.user)}
  let(:balance_transfer) { create(:balance_transfer, amount: 10, user: project.user, project: project)}
  let(:delegator) { balance_transfer.pagarme_delegator }

  before do
    allow(CatarsePagarme).to receive(:configuration).and_return(double('fake config', {
      slip_tax: 2.00,
      credit_card_tax: 0.01,
      pagarme_tax: 0.0063,
      cielo_tax: 0.038,
      stone_tax: 0.0307,
      stone_installment_tax: 0.0307,
      credit_card_cents_fee: 0.39,
      api_key: '',
      interest_rate: 0
    }))
  end

  describe "instance of CatarsePagarme::BalanceTransferDelegator" do
    it { expect(delegator).to be_a CatarsePagarme::BalanceTransferDelegator}
  end

  describe "#value_for_transaction" do
    subject { delegator.value_for_transaction }

    it "should convert balance value to pagarme value format" do
      expect(subject).to eq(1000)
    end
  end

  describe "#transfer_funds" do
    let(:transfer_mock) { double(create: true, id: "123", foo: false, to_hash: {id: '123'}, to_json: {id: '123'}.to_json) }
    let(:bank_acc_mock) { double(create: true, id: "1234")}
    before do
      allow(PagarMe::BankAccount).to receive(:new).and_return(bank_acc_mock)
      allow(PagarMe::Transfer).to receive(:new).and_return(transfer_mock)
    end

    context "when transfer is not authorized?" do
      before do
        allow(balance_transfer).to receive(:authorized?).and_return(false)
      end

      it do
        expect { delegator.transfer_funds }.to raise_error('unable to create transfer, need to be authorized')
      end
    end

    context "when transfer is authorized?" do
      before do
        allow(balance_transfer).to receive(:authorized?).and_return(true)
        allow(balance_transfer).to receive(:transition_to).and_return(true)
        expect(balance_transfer).to receive(:transition_to).with(:processing, transfer_data: transfer_mock.to_hash)
      end

      it do
        transfer = delegator.transfer_funds

        expect(transfer.transfer_id).to eq(transfer_mock.id)
      end
    end
  end
end
