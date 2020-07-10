# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe RefreshContributionRewardsMetricsTask, type: :model do
  context 'cache.refresh_contribution_reward_metrics' do
    let!(:project) { create(:project) }
    let!(:reward) { create(:reward, project: project) }
    let!(:confirmed_contribution) { create(:confirmed_contribution, project: project, reward: reward, created_at: 10.seconds.ago) }
    let(:payment) { confirmed_contribution.payments.last }

    it 'should call refresh_reward_metric_storage on found rewards' do
      expect(Reward).to receive(:find).with(reward.id).and_return(reward).at_least(:once)
      expect(reward).to receive(:refresh_reward_metric_storage).at_least(:once).and_call_original()
      Rake::Task["cache:refresh_contribution_reward_metrics"].invoke
    end
  end
end
