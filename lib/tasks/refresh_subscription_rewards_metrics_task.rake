# frozen_string_literal: true

class RefreshSubscriptionRewardsMetricsTask
  include Rake::DSL

  def initialize
    namespace :cache do
      task refresh_subscription_reward_metrics: :environment do
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
          SubscriptionPayment.where(sql_cond).pluck(:reward_id).uniq.each do |rid|
            reward = Reward.find_by common_id: rid
            reward.refresh_reward_metric_storage if reward.present?
          end
        end
      rescue StandardError => e
        Sentry.capture_exception(e, extra: { task: :refresh_subscription_reward_metrics })
      end

      break if Rails.env.test?
      sleep 5
    end
  end
end

RefreshSubscriptionRewardsMetricsTask.new
