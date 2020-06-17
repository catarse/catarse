# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RewardMetricStorageRefreshWorker do
  before do
    Sidekiq::Testing.inline!
  end

  describe 'perform' do
    let(:reward) { create(:reward, maximum_contributions: 20) }
    before do
      create(:confirmed_contribution, reward: reward, project: reward.project)
      create(:pending_contribution, reward: reward, project: reward.project)
      payment = create(:pending_contribution, reward: reward, project: reward.project).payments.first
      payment.update_column(:created_at, 8.days.ago)

    end

    before do
      expect(Reward).to receive(:find).with(reward.id).and_return(reward)
      expect(reward).to receive(:refresh_reward_metric_storage)
    end
    it 'should call refresh function' do
      RewardMetricStorageRefreshWorker.perform_async(reward.id)
    end
  end
end
