class Channels::Admin::Reports::SubscriberReportsController < Admin::Reports::BaseController

  private
  def begin_of_association_chain
    Channel.find_by_permalink!(request.subdomain.to_s)
  end
end
