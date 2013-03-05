class Channels::ProfilesController < Channels::BaseController
  inherit_resources
  actions :show


  def show
    @profile = Channel::Profile.find_by_permalink!(params[:permalink])
    show!
  end




end
