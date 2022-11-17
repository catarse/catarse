# frozen_string_literal: true

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
        ActiveRecord::Base.connection_pool.with_connection do
          Contribution.where(sql_cond).pluck(:reward_id).uniq.each do |rid|
            reward = Reward.find rid
            reward.refresh_reward_metric_storage
          end
        end
      rescue StandardError => e
        Sentry.capture_exception(e, extra: { task: :refresh_contribution_reward_metrics })
      end

      break if Rails.env.test?
      sleep 5
    end
  end
end

RefreshContributionRewardsMetricsTask.new
