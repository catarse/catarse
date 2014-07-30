class Channels::Admin::Reports::SubscriberReportsController < Channels::Admin::BaseController
  include Concerns::Admin::ReportsHandler
  actions :index

  private
  def end_of_association_chain
    SubscriberReport.where(channel_id: channel.id)
  end
end
