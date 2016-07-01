require 'rails_helper'

RSpec.describe BalanceTransfer, type: :model do
  let(:project) { create(:project, state: 'successful') }
  let(:balance_transfer) { create(:balance_transfer, project: project) }
  let(:pagarme_delegator_mock) { double(transfer_funds: true)}

  before do
    #allow(balance_transfer).to receive(
    #  :pagarme_delegator).and_return(pagarme_delegator_mock)
  end

  describe 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :transitions }
  end

  describe 'from pending to authorized' do
    it do
      #expect(balance_transfer.pagarme_delegator).to receive(:transfer_funds)
      expect(balance_transfer.project).to receive(:notify).with(:project_balance_transferred, balance_transfer.project.user, balance_transfer.project)
      balance_transfer.transition_to(:authorized)
    end
  end
end
