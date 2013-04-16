class Channels::ChannelsSubscribersController < Channels::BaseController
  inherit_resources
  load_and_authorize_resource
  actions :index, :create, :destroy

  alias_method :index, :create
  def create
    begin
      create! do |success,failure|
        success.html{ return redirect_to root_path }
      end
    rescue ActiveRecord::RecordNotUnique => e
      return redirect_to root_path
    end
  end

  def destroy
    destroy! do |success,failure|
      success.html{ return redirect_to root_path }
    end
  end

  prepend_before_filter do
    params[:channels_subscriber] = { channel_id: Channel.find_by_permalink!(request.subdomain).id, user_id: current_user.id } if current_user
  end
end

