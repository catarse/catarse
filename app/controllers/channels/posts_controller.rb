class Channels::PostsController < Channels::BaseController
  layout 'catarse_bootstrap'
  inherit_resources

  def index
    @post = ChannelPost.new(channel_id: channel.id, user_id: current_user.id) if current_user
  end

  private

  def begin_of_association_chain
    channel
  end
end
