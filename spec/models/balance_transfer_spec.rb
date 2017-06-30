# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BalanceTransfer, type: :model do
  let(:project) { create(:project, state: 'successful') }
  let(:balance_transfer) { create(:balance_transfer, amount: 100, project: project) }
  let(:transfer_funds_return) { true }
  let(:pagarme_delegator_mock) { double(transfer_funds: transfer_funds_return) }

  before do
    # allow(balance_transfer).to receive(
    #  :pagarme_delegator).and_return(pagarme_delegator_mock)
  end

  describe 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many :transitions }
    it { is_expected.to have_many :balance_transactions }
  end

  describe 'from processing to error' do
    it 'should refund balance' do
      balance_transfer.transition_to(:authorized)
      balance_transfer.transition_to(:processing)
      expect(balance_transfer).to receive(:refund_balance).and_call_original
      expect(Notification).to receive(:notify).with(:balance_transfer_error, balance_transfer.user, { associations: { balance_transfer_id: balance_transfer.id } })
      balance_transfer.transition_to(:error)
      balance_transfer.reload
      expect(balance_transfer.balance_transactions.last).not_to be_nil
    end
  end

  describe 'from authorized to rejected' do
    it 'should refund balance' do
      balance_transfer.transition_to(:authorized)
      expect(balance_transfer).to receive(:refund_balance).and_call_original
      expect(Notification).to receive(:notify).with(:balance_transfer_error, balance_transfer.user, { associations: { balance_transfer_id: balance_transfer.id } })
      balance_transfer.transition_to(:rejected)
      balance_transfer.reload
      expect(balance_transfer.balance_transactions.last).not_to be_nil
    end
  end

  describe 'from processing to transferred' do
    it 'should not notify when skip notification on transition' do
      balance_transfer.transition_to(:authorized)
      balance_transfer.transition_to(:processing)
      expect(Notification).not_to receive(:notify).with(:balance_transferred, balance_transfer.user, { associations: { balance_transfer_id: balance_transfer.id} })
      balance_transfer.transition_to(:transferred, {skip_notification: true})
    end
    it 'sould notify about transferred' do
      balance_transfer.transition_to(:authorized)
      balance_transfer.transition_to(:processing)
      expect(Notification).to receive(:notify).with(:balance_transferred, balance_transfer.user, { associations: { balance_transfer_id: balance_transfer.id} })
      balance_transfer.transition_to(:transferred)
    end
  end

  describe '.refund_balance' do
    context 'when balance transfer is not refunded' do
      context "and state is pending" do
        subject { balance_transfer.refund_balance }
        it { is_expected.to eq(nil) }
      end

      context "and state is authorized" do
        before do
          allow(balance_transfer).to receive(:state).and_return("authorized")
        end
        subject { balance_transfer.refund_balance }
        it { is_expected.to eq(nil) }
      end

      context "and state is processing" do
        before do
          allow(balance_transfer).to receive(:state).and_return("processing")
        end
        subject { balance_transfer.refund_balance }
        it { is_expected.to eq(nil) }
      end

      context "and state is transferred" do
        before do
          allow(balance_transfer).to receive(:state).and_return("transferred")
        end
        subject { balance_transfer.refund_balance }
        it { is_expected.to eq(nil) }
      end

      context "and state is error" do
        before do
          allow(balance_transfer).to receive(:state).and_return("error")
          @refund_balance = balance_transfer.refund_balance
        end

        it { expect(@refund_balance).to eq(balance_transfer.balance_transactions.where(event_name: 'balance_transfer_error').last) }

        it "should return nil when already refunded" do
          expect(balance_transfer.refund_balance).to eq(nil)
        end
      end

      context "and state is rejected" do
        before do
          allow(balance_transfer).to receive(:state).and_return("rejected")
          @refund_balance = balance_transfer.refund_balance
        end

        it { expect(@refund_balance).to eq(balance_transfer.balance_transactions.where(event_name: 'balance_transfer_error').last) }

        it "should return nil when already refunded" do
          expect(balance_transfer.refund_balance).to eq(nil)
        end
      end
    end
  end

end
