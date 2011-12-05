class ExploreController < ApplicationController
  def index
    @title = t('explore.title')
    @categories = Category.with_projects.order(:name).all
    @recommended = Project.visible.recommended.order('created_at DESC').all
    @expiring = Project.visible.expiring.limit(16).order('expires_at').all
    @recent = Project.visible.recent.limit(16).order('created_at DESC').all
    @successful = Project.visible.successful.order('expires_at DESC').all
    @all = Project.visible.order('created_at DESC').all
  end
end