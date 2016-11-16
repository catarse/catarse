require 'rails_helper'

RSpec.describe BalanceTransfer, type: :model do
  let(:project) { create(:project, state: 'successful') }
  let(:balance_transfer) { create(:balance_transfer, amount: 100, project: project) }
  let(:pagarme_delegator_mock) { double(transfer_funds: true) }
  let(:total_amount) { 100 }
  let(:project_transfer_mock) { double(total_amount: total_amount) }

  before do
    allow(project).to receive(:project_transfer).
      and_return(project_transfer_mock)

    #allow(balance_transfer).to receive(
    #  :pagarme_delegator).and_return(pagarme_delegator_mock)
  end

  describe 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :transitions }
  end

  describe 'from processing to transferred' do
    it do
      balance_transfer.transition_to(:authorized)
      balance_transfer.transition_to(:processing)
      #expect(balance_transfer.pagarme_delegator).to receive(:transfer_funds)
      expect(balance_transfer.project).to receive(:notify).with(:project_balance_transferred, balance_transfer.project.user, balance_transfer.project)
      balance_transfer.transition_to(:transferred)
    end
  end

  describe '#refresh_project_amount' do
    let(:total_amount) { 90 }

    it "should update amount with changed_amount" do
      expect(balance_transfer.amount.to_f).to be 100.0
      balance_transfer.refresh_project_amount
      expect(balance_transfer.amount.to_f).to be 90.0
    end
  end

  describe 'project_amount_changed?' do
    subject { balance_transfer.project_amount_changed? }

    it 'should be false when project transfer total amount is eq' do
      is_expected.to be false
    end

    context 'when total amount changed after balance transfer as created' do
      let(:total_amount) { 90 }
      it 'should be true' do
        is_expected.to be true
      end
    end

  end
end
