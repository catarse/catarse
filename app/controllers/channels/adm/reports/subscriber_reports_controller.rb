class Channels::Adm::Reports::SubscriberReportsController < Adm::Reports::BaseController

  private
  def begin_of_association_chain
    Channel.find_by_permalink!(request.subdomain.to_s)
  end
end
