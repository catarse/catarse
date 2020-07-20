# frozen_string_literal: true

class PaymentNotification < ActiveRecord::Base
  belongs_to :contribution
  serialize :extra_data, JSON

  after_commit :schedule_refresh_metric_storages, on: :create

  def schedule_refresh_metric_storages
    return unless self.contribution.present?
    return unless self.contribution.reward.present?
    RewardMetricStorageRefreshWorker.perform_in(5.seconds, contribution.reward_id)
  end

  # This methods should be called by payments engines
  def deliver_process_notification
    deliver_contributor_notification(:processing_payment)
  end

  def deliver_slip_canceled_notification
    deliver_contributor_notification(:contribution_canceled_slip)
  end

  private

  def deliver_contributor_notification(template_name)
    contribution.notify_to_contributor(template_name)
  end
end
