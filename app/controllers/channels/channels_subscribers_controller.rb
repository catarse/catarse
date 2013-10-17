class Channels::ChannelsSubscribersController < Channels::BaseController
  inherit_resources
  load_and_authorize_resource
  actions :create, :destroy

  def create
    @channels_subscriber = ChannelsSubscriber.new subscription_attributes
    create! do |format|
      flash[:notice] = I18n.t('channels_subscribers.created', channel: channel.name)
      return redirect_to root_path
    end
  end

  def destroy
    destroy! do |format|
      flash[:notice] = I18n.t('channels_subscribers.deleted', channel: channel.name)
      return redirect_to root_path
    end
  end

  def resource
    @channels_subscriber ||= ChannelsSubscriber.where(subscription_attributes).first!
  end

  private
  def subscription_attributes
    { channel_id: channel.id, user_id: current_user.id }
  end
end

