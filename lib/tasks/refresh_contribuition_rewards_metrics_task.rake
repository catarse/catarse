class RefreshContributionRewardsMetricsTask
  include Rake::DSL

  def initialize
    namespace :cache do
      task refresh_contribution_reward_metrics: :environment do
        call
      end
    end
  end

  private

  def call
    sql_cond = "reward_id is not null and (created_at >= now() - '30 seconds'::interval) or (updated_at >= now() - '30 seconds'::interval)"

    loop do
      begin
        Contribution.where(sql_cond).pluck(:reward_id).uniq.each do |rid|
          reward = Reward.find rid
          reward.refresh_reward_metric_storage
        end
      rescue StandardError => e
        Raven.extra_context(task: :refresh_contribution_reward_metrics)
        Raven.capture_exception(e)
        Raven.extra_context({})
      end

      break if Rails.env.test?
      sleep 5
    end
  end
end

RefreshContributionRewardsMetricsTask.new
