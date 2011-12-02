class ExploreController < ApplicationController
  def index
    @title = t('explore.title')
    @categories = Category.with_projects(current_site).order(:name).all
    @recommended = current_site.present_projects.visible.recommended.order('created_at DESC').all
    @expiring = current_site.present_projects.visible.expiring.limit(16).order('expires_at').all
    @recent = current_site.present_projects.visible.recent.limit(16).order('created_at DESC').all
    @successful = current_site.present_projects.visible.successful.order('expires_at DESC').all
    @all = current_site.present_projects.visible.order('created_at DESC').all
  end
end