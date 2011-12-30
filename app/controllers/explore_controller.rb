class ExploreController < ApplicationController

  def index
    @title = t('explore.title')
    @categories = Category.with_projects.order(:name).all
    @recommended = (Project.visible.not_expired.recommended.order('expires_at').length > 0)
    @expiring = (Project.visible.expiring.limit(16).order('expires_at').length > 0)
    @recent = (Project.visible.recent.not_expired.limit(16).order('created_at DESC').length > 0)
    @successful = (Project.visible.successful.order('expires_at DESC').length > 0)
  end

end
