# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe RefreshPaymentRewardsMetricsTask, type: :model do
  context 'cache.refresh_payment_reward_metrics' do
    let!(:project) { create(:project) }
    let!(:reward) { create(:reward, project: project) }
    let!(:confirmed_contribution) { create(:confirmed_contribution, project: project, reward: reward, created_at: 10.seconds.ago) }
    let(:payment) { confirmed_contribution.payments.last }

    it 'should call refresh_reward_metric_storage on found rewards' do
      expect(Contribution).to receive(:find).with(confirmed_contribution.id).and_return(confirmed_contribution).at_least(:once)
      expect(reward).to receive(:refresh_reward_metric_storage).and_call_original().at_least(:once)
      Rake::Task["cache:refresh_payment_reward_metrics"].invoke
    end
  end
end
