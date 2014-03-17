class Channels::ProfilesController < Channels::BaseController
  layout 'catarse_bootstrap'
  inherit_resources
  actions :show, :edit, :update
  custom_actions resource: [:how_it_works]
  after_filter :verify_authorized, except: [:how_it_works, :show]

  def edit
    authorize resource
    edit!
  end

  def update
    authorize resource
    update!
  end

  def resource
    @profile ||= channel
  end
end
