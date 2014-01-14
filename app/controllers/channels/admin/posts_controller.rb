class Channels::Admin::PostsController < Admin::BaseController
  layout 'catarse_bootstrap'
  inherit_resources
  defaults resource_class: ChannelPost

  def begin_of_association_chain
    channel
  end

  def collection
    @posts ||= apply_scopes(end_of_association_chain.ordered.page(params[:page]))
  end

  protected

  def create_resource(object)
    object.user = current_user
    super
  end
end
