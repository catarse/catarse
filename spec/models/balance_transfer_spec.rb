require 'rails_helper'

RSpec.describe BalanceTransfer, type: :model do
  let(:project) { create(:project, state: 'successful') }
  let(:balance_transfer) { create(:balance_transfer, amount: 100, project: project) }
  let(:transfer_funds_return) { true }
  let(:pagarme_delegator_mock) { double(transfer_funds: transfer_funds_return) }

  before do
    #allow(balance_transfer).to receive(
    #  :pagarme_delegator).and_return(pagarme_delegator_mock)
  end

  describe 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :transitions }
    it { is_expected.to have_many :balance_transactions }
  end

  describe 'from processing to error' do
    it "should refund balance" do
        balance_transfer.transition_to(:authorized)
        balance_transfer.transition_to(:processing)
        expect(balance_transfer).to receive(:refund_balance).and_call_original
        balance_transfer.transition_to(:error)
        balance_transfer.reload
        expect(balance_transfer.balance_transactions.last).not_to be_nil
    end
  end

  describe 'from processing to transferred' do
    it "sould notify about transferred" do
      balance_transfer.transition_to(:authorized)
      balance_transfer.transition_to(:processing)
      #expect(balance_transfer.pagarme_delegator).to receive(:transfer_funds)
      expect(balance_transfer.project).to receive(:notify).with(:project_balance_transferred, balance_transfer.project.user, balance_transfer.project)
      balance_transfer.transition_to(:transferred)
    end
  end
end
