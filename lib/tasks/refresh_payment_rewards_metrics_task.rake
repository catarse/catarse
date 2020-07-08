class RefreshPaymentRewardsMetricsTask
  include Rake::DSL

  def initialize
    namespace :cache do
      task refresh_payment_reward_metrics: :environment do
        call
      end
    end
  end

  private

  def call
    sql_cond = "(created_at >= now() - '30 seconds'::interval) or (updated_at >= now() - '30 seconds'::interval)"

    loop do
      begin
        Payment.where(sql_cond).pluck(:contribution_id).uniq.each do |cid|
          contribution = Contribution.find cid
          if contribution.reward.present?
            contribution.reward.refresh_reward_metric_storage
          end
        end
      rescue StandardError => e
        Raven.extra_context(task: :refresh_payment_reward_metrics)
        Raven.capture_exception(e)
        Raven.extra_context({})
      end

      break if Rails.env.test?
      sleep 5
    end
  end
end

RefreshPaymentRewardsMetricsTask.new
