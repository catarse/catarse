
# frozen_string_literal: true

require 'rails_helper'

Rails.application.load_tasks

RSpec.describe RefreshSubscriptionRewardsMetricsTask, type: :model do
  context 'cache.refresh_payment_reward_metrics' do
    let!(:project) { create(:subscription_project) }
    let!(:reward) { create(:reward, project: project, common_id: SecureRandom.uuid) }
    let!(:subscription_payment) { OpenStruct.new(reward: reward, reward_id: reward.common_id) }

    before do
      allow(SubscriptionPayment).to receive_message_chain(:where, :pluck, :uniq).and_return([subscription_payment.reward_id])
      expect(Reward).to receive(:find_by).and_return(reward).at_least(:once)
      expect(reward).to receive(:refresh_reward_metric_storage).at_least(:once).and_call_original().at_least(:once)
    end

    it 'should call refresh_reward_metric_storage on found rewards' do
      Rake::Task["cache:refresh_subscription_reward_metrics"].invoke
    end
  end
end
