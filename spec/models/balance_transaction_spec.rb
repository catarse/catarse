# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BalanceTransaction, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
    it { is_expected.to belong_to(:contribution) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_presence_of(:event_name) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_inclusion_of(:event_name).in_array(%w[successful_project_pledged catarse_project_service_fee irrf_tax_project]) }
  end

  describe '#insert_contribution_confirmed_after_project_finished' do
    let(:project) { create(:project, goal: 30, state: 'online') }
    let!(:contribution) { create(:confirmed_contribution, value: 200, project: project) }
    let!(:pending_contribution) { create(:pending_contribution, value: 200, project: project, created_at: 20.days.ago) }
    let!(:pending_contribution_2) { create(:pending_contribution, value: 15, project: project, created_at: 22.days.ago) }

    before do
      project.update_attributes(expires_at: 10.days.ago)
      expect(BalanceTransaction).to receive(:insert_successful_project_transactions).with(project.id).and_call_original
      project.finish
    end

    context 'when pending contribution is confirmed after project successful' do
      before do
        expect(BalanceTransaction).to receive(:insert_contribution_confirmed_after_project_finished).with(project.id, pending_contribution.id).and_call_original
        pending_contribution.payments.last.pay
        project.reload
      end

      it 'should create the balance transaction for contribution' do
        bt = pending_contribution.balance_transactions
        expect(bt.where(
          event_name: 'project_contribution_confirmed_after_finished',
          amount: pending_contribution.value
        ).exists?).to eq(true)

        expect(bt.where(
          event_name: 'catarse_contribution_fee',
          amount: (pending_contribution.value * pending_contribution.project.service_fee) * -1
        ).exists?).to eq(true)

        expect(BalanceTransaction).to receive(:insert_contribution_confirmed_after_project_finished).with(project.id, pending_contribution_2.id).and_call_original
        pending_contribution_2.payments.last.pay

        bt = pending_contribution_2.balance_transactions
        expect(bt.where(
          event_name: 'project_contribution_confirmed_after_finished',
          amount: pending_contribution_2.value
        ).exists?).to eq(true)

        expect(bt.where(
          event_name: 'catarse_contribution_fee',
          amount: (pending_contribution_2.value * pending_contribution_2.project.service_fee) * -1
        ).exists?).to eq(true)
      end
    end
  end

  describe '#insert_successful_project_transactions' do
    let(:project) { create(:project, goal: 30, state: 'online') }
    let!(:contribution) { create(:confirmed_contribution, value: 20_000, project: project) }

    context 'when given project is finished' do
      before do
        project.update_attributes(expires_at: 2.minutes.ago)
        expect(BalanceTransaction).to receive(:insert_successful_project_transactions).with(project.id).and_call_original
        project.finish
        project.reload
      end

      it 'should create successful_project_pledged transaction' do
        expect(BalanceTransaction.find_by(event_name: 'successful_project_pledged', project_id: project.id, user_id: project.user_id, amount: project.paid_pledged)).not_to be_nil
      end

      it 'should create catarse_project_service_fee transaction' do
        expect(BalanceTransaction.find_by(event_name: 'catarse_project_service_fee', project_id: project.id, user_id: project.user_id, amount: project.total_catarse_fee * -1)).not_to be_nil
      end
    end

    context 'when project owner is pj' do
      before do
        contribution.payments.last.update_attributes(gateway_fee: '400')
        project.user.update_attributes(account_type: 'pj', cpf: '38.414.365/0001-35')
        project.update_attributes(expires_at: 2.minutes.ago)
        project.finish
      end

      it 'should create irrf_tax_project transaction' do
        expect(BalanceTransaction.find_by(event_name: 'irrf_tax_project', project_id: project.id, user_id: project.user_id, amount: project.irrf_tax)).not_to be_nil
      end
    end

    context 'when project is not successful yet' do
      let(:project) { create(:project, state: 'online') }
      subject { BalanceTransaction.insert_successful_project_transactions(project.id) }
      it 'should return nothing' do
        is_expected.to eq(nil)
      end
    end
  end

  describe 'insert_contribution_refund' do
    let(:project) { create(:project, goal: 30, state: 'online') }
    let!(:contribution) { create(:confirmed_contribution, value: 200, project: project) }

    context 'when contribution already refunded' do
      before do
        BalanceTransaction.insert_contribution_refund(contribution.id)
      end

      it "should return at second try nil" do
        expect(contribution.balance_refunded?).to eq(true)
        expect(BalanceTransaction.insert_contribution_refund(contribution.id)).to eq(nil)
        expect(BalanceTransaction.where(event_name: 'contribution_refund', contribution_id: contribution.id).count).to eq(1)
      end
    end

    context 'when contributions is not confirmed' do
      before do
        allow(Contribution).to receive(:find).with(contribution.id).and_return(contribution)
        allow(contribution).to receive(:confirmed?).and_return(false)
        expect(contribution).not_to receive(:balance_refunded?)
      end

      it "should return nil" do
        expect(BalanceTransaction.insert_contribution_refund(contribution.id)).to eq(nil)
        expect(BalanceTransaction.where(event_name: 'contribution_refund', contribution_id: contribution.id).count).to eq(0)
      end
    end

    context 'when contribution is avaiable to refund in balance' do
      it "should create balance transaction" do
        balance_transaction = BalanceTransaction.insert_contribution_refund(contribution.id)
        expect(contribution.balance_refunded?).to eq(true)
        expect(balance_transaction.event_name).to eq('contribution_refund')
        expect(balance_transaction.amount).to eq(contribution.value)

      end
    end


  end

end
