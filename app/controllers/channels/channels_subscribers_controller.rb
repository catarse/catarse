class Channels::ChannelsSubscribersController < Channels::BaseController
  inherit_resources
  load_and_authorize_resource
  actions :create, :destroy
  respond_to :json

  prepend_before_filter do
    params[:channels_subscriber] = { channel_id: Channel.find_by_permalink!(request.subdomain).id, user_id: current_user.id }
  end
end

