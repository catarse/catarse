class Channels::ProfilesController < Channels::BaseController
  layout :use_catarse_boostrap
  inherit_resources
  enable_authorization only: [:edit, :update]
  actions :show, :edit, :update
  custom_actions resource: [:how_it_works, :new_how_it_works, :new_channel_home]

  def resource
    @profile ||= channel
  end

  private
  def use_catarse_boostrap
    action_name == 'new_channel_home' || action_name == 'new_how_it_works' ? 'catarse_bootstrap' : 'application'
  end
end
