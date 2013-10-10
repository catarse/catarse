class Channels::ChannelsSubscribersController < Channels::BaseController
  inherit_resources
  load_and_authorize_resource
  actions :create, :destroy

  def create
    begin
      @channels_subscriber = ChannelsSubscriber.new subscription_attributes
      create! do |format|
        flash[:notice] = I18n.t('channels_subscribers.created')
        return redirect_to root_path
      end
    rescue PG::Error, ActiveRecord::RecordNotUnique
      return redirect_to root_path
    end
  end

  def destroy
    destroy! do |format|
      flash[:notice] = I18n.t('channels_subscribers.deleted')
      return redirect_to root_path
    end
  end

  def resource
    @channels_subscriber ||= ChannelsSubscriber.where(subscription_attributes).first! if current_user
  end

  private
  def subscription_attributes
    { channel_id: Channel.find_by_permalink!(request.subdomain).id, user_id: current_user.id }
  end
end

