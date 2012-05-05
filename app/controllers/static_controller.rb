class StaticController < ApplicationController

  def new_home
  end

  def new_blog
  end

  def new_profile
  end

  def new_project_profile
  end

  def new_discover
  end

  def new_payment
  end

  def new_opendata
  end

  def guidelines
    @title = t('static.guidelines.title')
  end

  def faq
    @title = t('static.faq.title')
  end

  def sitemap
    # TODO: update this sitemap to use new homepage logic
    @home_page = Project.includes(:user, :category).visible.home_page.limit(6).order('"order"').all
    @expiring = Project.includes(:user, :category).visible.expiring.not_home_page.not_expired.order('expires_at, created_at DESC').limit(3).all
    @recent = Project.includes(:user, :category).visible.not_home_page.not_expiring.not_expired.where("projects.user_id <> 7329").order('created_at DESC').limit(3).all
    @successful = Project.includes(:user, :category).visible.not_home_page.successful.order('expires_at DESC').limit(3).all
    return render 'sitemap'
  end

end