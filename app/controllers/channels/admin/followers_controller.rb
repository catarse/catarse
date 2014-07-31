class Channels::Admin::FollowersController < Channels::Admin::BaseController
  actions :index

  before_filter do
    @channel = Channel.find_by_permalink!(request.subdomain.to_s)
  end

  def index
    @total_subscribers = @channel.subscribers.count(:all)
    @subscribers = channel.subscribers.page(params[:page])
  end
end
