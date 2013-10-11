class Channels::Admin::Reports::SubscriberReportsController < Admin::Reports::BaseController
  private
  def end_of_association_chain
    SubscriberReport.where(channel_id: channel.id)
  end
end
