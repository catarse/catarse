class Channels::ProfilesController < Channels::BaseController
  layout 'catarse_bootstrap'
  add_to_menu 'channels.adm.profile_menu', :edit_channels_profile_path
  inherit_resources
  actions :show, :edit, :update
  custom_actions resource: [:how_it_works]

  before_action only: [:edit, :update] do
    authorize!(params[:action], resource)
  end

  def resource
    @profile ||= channel
  end
end
