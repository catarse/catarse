class Channels::ProfilesController < Channels::BaseController
  layout 'catarse_bootstrap'
  inherit_resources
  enable_authorization only: [:edit, :update]
  actions :show, :edit, :update
  custom_actions resource: [:how_it_works]

  def resource
    @profile ||= channel
  end
end
