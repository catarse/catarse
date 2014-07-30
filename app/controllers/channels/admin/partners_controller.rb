class Channels::Admin::PartnersController < Channels::Admin::BaseController
  defaults resource_class: ChannelPartner

  def update
    update! { channels_admin_partners_path }
  end

  def create
    create! { channels_admin_partners_path }
  end

  def begin_of_association_chain
    channel
  end

  def collection
    @partners ||= apply_scopes(end_of_association_chain.ordered.page(params[:page]))
  end
end
