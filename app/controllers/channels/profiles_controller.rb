class Channels::ProfilesController < Channels::BaseController
  inherit_resources
  defaults resource_class: Channel, finder: :find_by_permalink! 
  actions :show
  before_filter{ params[:id] = request.subdomain }
end
