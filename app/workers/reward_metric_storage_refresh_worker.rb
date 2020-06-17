# frozen_string_literal: true

class RewardMetricStorageRefreshWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'metric_storage'

  def perform(id)
    resource = Reward.find id
    resource.refresh_reward_metric_storage
  end
end
