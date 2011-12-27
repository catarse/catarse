class ExploreController < ApplicationController

  def index
    @title = t('explore.title')
    @categories = Category.with_projects.order(:name).all
    @recommended = Project.visible.not_expired.recommended.order('expires_at').all
    @expiring = Project.visible.expiring.limit(16).order('expires_at').all
    @recent = Project.visible.recent.not_expired.limit(16).order('created_at DESC').all
    @successful = Project.visible.successful.order('expires_at DESC').all
  end

end
