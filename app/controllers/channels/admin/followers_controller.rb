class Channels::Admin::FollowersController < Admin::BaseController
  layout 'catarse_bootstrap'
  actions :index

  before_filter do
    @channel = Channel.find_by_permalink!(request.subdomain.to_s)
  end

  def index
    @total_subscribers = @channel.subscribers.count
    @subscribers = channel.subscribers.page(params[:page])
  end
end
