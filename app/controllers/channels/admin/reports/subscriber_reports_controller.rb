class Channels::Admin::Reports::SubscriberReportsController < Admin::Reports::BaseController

  private
  def end_of_association_chain
    SubscriberReport.where(channel_id: Channel.find_by_permalink!(request.subdomain.to_s).id)
  end
end
