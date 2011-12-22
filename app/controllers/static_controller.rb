class StaticController < ApplicationController

  def sitemap
    @home_page = Project.includes(:user, :category).visible.home_page.limit(6).order('"order"').all
    @expiring = Project.includes(:user, :category).visible.expiring.not_home_page.not_successful.not_unsuccessful.order('expires_at, created_at DESC').limit(3).all
    @recent = Project.includes(:user, :category).visible.not_home_page.not_expiring.not_successful.not_unsuccessful.where("projects.user_id <> 7329").order('created_at DESC').limit(3).all
    @successful = Project.includes(:user, :category).visible.not_home_page.successful.order('expires_at DESC').limit(3).all
  end

end