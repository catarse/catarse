class Channels::ProfilesController < Channels::BaseController
  layout :user_catarse_bootstrap
  inherit_resources
  load_and_authorize_resource only: [:edit, :update]
  actions :show, :edit, :update
  custom_actions resource: [:how_it_works]

  def resource
    @profile ||= channel
  end

  private
  def user_catarse_bootstrap
    action_name == 'edit' ? 'application' : 'catarse_bootstrap'
  end
end
