class Channels::ChannelsSubscribersController < Channels::BaseController
  inherit_resources
  load_and_authorize_resource
  actions :index, :create, :destroy

  # we skid the set_locale because we are using the index method to create a record
  skip_before_filter :set_locale

  def create
    begin
      create! do |success,failure|
        success.html{
          flash[:notice] = I18n.t('channels_subscribers.created')
          return redirect_to root_path }
      end
    rescue PG::Error, ActiveRecord::RecordNotUnique => e
      return redirect_to root_path
    end
  end
  alias_method :index, :create

  def destroy
    destroy! do |success,failure|
      success.html{
        flash[:notice] = I18n.t('channels_subscribers.deleted')
        return redirect_to root_path
      }
    end
  end

  prepend_before_filter do
    params[:channels_subscriber] = { channel_id: Channel.find_by_permalink!(request.subdomain).id, user_id: current_user.id } if current_user
  end
end

