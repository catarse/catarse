class ExploreController < ApplicationController
  layout 'redesign'

  def index
    @title = t('explore.title')
    @categories = Category.with_projects.order(:name).all
    @recommended = Project.visible.not_expired.recommended.order('expires_at').limit(3)
    @expiring = Project.visible.expiring.limit(3).order('expires_at')
    @recent = Project.visible.recent.not_expired.limit(3).order('created_at DESC')
    @successful = Project.visible.successful.order('expires_at DESC').limit(3)
  end

end
