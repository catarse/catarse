class Channels::Admin::StatisticsController < Admin::BaseController
  layout 'catarse_bootstrap'
  actions :index

  before_filter do
    @channel = Channel.find_by_permalink!(request.subdomain.to_s)
  end

  def index
    @total_subscribers = @channel.subscribers.count
  end
end
