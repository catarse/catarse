class Channels::PostsController < Channels::BaseController
  layout 'catarse_bootstrap'
  inherit_resources

  private

  def begin_of_association_chain
    channel
  end

  def end_of_association_chain
    begin_of_association_chain.channel_posts.visible
  end
end
