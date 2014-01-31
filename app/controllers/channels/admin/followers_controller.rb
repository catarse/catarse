class Channels::Admin::FollowersController < Admin::BaseController
  layout 'catarse_bootstrap'
  add_to_menu "channels.admin.followers_menu", :channels_admin_followers_path
  actions :index

  before_filter do
    @channel = Channel.find_by_permalink!(request.subdomain.to_s)
  end

  def index
    @total_subscribers = @channel.subscribers.count
    @subscribers = channel.subscribers.page(params[:page])
  end
end
