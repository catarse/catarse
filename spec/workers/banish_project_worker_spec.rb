# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BanishProjectWorker do
  let(:project) { create(:project) }
  let(:user) { create(:user) }

  before do
    Sidekiq::Testing.inline!
  end

  context 'when project exist' do
    context "when project is flex" do
      let(:confirmed_contribution) { create(:confirmed_contribution, project_id: project.id, user_id: user.id) }
      let(:payment) { confirmed_contribution.payments.first }

      before do
        expect(BalanceTransaction).to receive(:insert_contribution_refund).with(payment.contribution_id)
        expect(BalanceTransaction).to receive(:insert_contribution_refunded_after_successful_pledged).with(payment.contribution_id)
        expect(project.user.banned_at).to eq(nil)
        expect(project.push_to_trash).to be_truthy
      end

      it 'should refund on balance' do
        BanishProjectWorker.perform_async(project.id)
      end
    end

    context "when project is sub" do
      before do
        allow(project).to receive(:is_sub?).and_return(true)
        expect(project.user.banned_at).to eq(nil)
        expect(project.push_to_trash).to be_truthy
      end

      it 'should refund on balance' do
        BanishProjectWorker.perform_async(project.id)
      end
    end
  end

  context 'when project not exist' do
    it 'should return an error' do
      BanishProjectWorker.perform_async(11111111111)
      expect { raise StandardError }.to raise_error
    end
  end
end
