class ExploreController < ApplicationController
  def index
    @title = t('explore.title')
    @categories = Category.with_projects.order(:name_pt).all

    # Just to know if we should present the menu entries, the actual projects are fetched via AJAX
    @recommended = Project.visible.not_expired.recommended.limit(1)
    @expiring = Project.visible.expiring.limit(1)
    @recent = Project.visible.recent.not_expired.limit(1).order('created_at DESC')
    @successful = Project.visible.successful.limit(1)
  end

end
