class Channels::ProjectsController < ProjectsController
  layout 'catarse_bootstrap'
  belongs_to :channel, finder: :find_by_permalink!, param: :profile_id


  # Inheriting from the original Projects controller
  # With one addition: we include the project into the current channel
  before_filter only: [:create] { params[:project][:channels] = [channel] }

  prepend_before_filter{ params[:profile_id] = request.subdomain }
end


