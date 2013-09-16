class Channels::ProfilesController < Channels::BaseController
  layout :use_catarse_boostrap
  inherit_resources
  defaults resource_class: Channel, finder: :find_by_permalink! 
  actions :show
  custom_actions resource: [:how_it_works, :new_channel_home]

  before_filter{ params[:id] = request.subdomain }

  private
  def use_catarse_boostrap
    action_name == 'new_channel_home' ? 'catarse_bootstrap' : 'application'
  end
end
