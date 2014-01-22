class Channels::Admin::PostsController < Admin::BaseController
  layout 'catarse_bootstrap'
  add_to_menu 'channels.admin.posts_menu', :channels_admin_posts_path
  load_and_authorize_resource :channel_posts
  inherit_resources
  defaults resource_class: ChannelPost

  def create
    create! { channels_admin_posts_path }
  end

  def update
    update! { channels_admin_posts_path }
  end

  def begin_of_association_chain
    channel
  end

  def collection
    @posts ||= apply_scopes(end_of_association_chain.ordered.page(params[:page]))
  end

  protected

  def create_resource(object)
    object.user_id = current_user.id
    super
  end
end
