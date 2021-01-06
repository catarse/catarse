class DispatchRewardMetricStorageRefreshTask
  include Rake::DSL

  def initialize
    namespace :rewards do
      task dispatch_metric_storage_refresh: :environment do
        call
      end

      # NOTE: this cmd is only for sandbox environment
      task dispatch_metric_storage_refresh_loop: :environment do
        raise 'run only in sandox' unless Rails.env.sandbox?
        loop do
          call
          sleep 300
        end
      end
    end
  end

  private

  def call
    RewardMetricStorage
      .joins(reward: :project)
      .where("refreshed_at < now() - '5 minutes'::interval")
      .where(projects: { state: %i[online waiting_funds] })
      .pluck(:reward_id)
      .each do |id|
      RewardMetricStorageRefreshWorker.perform_async(id)
    end
  end
end

DispatchRewardMetricStorageRefreshTask.new
