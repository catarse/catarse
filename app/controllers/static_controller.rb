class StaticController < ApplicationController
  def guidelines
    @title = t('static.guidelines.title')
  end

  def guidelines_tips
    @title = t('static.guidelines_tips.title')
  end

  def faq
    @title = t('static.faq.title')
  end

  def thank_you
    backer = Backer.find session[:thank_you_backer_id]
    redirect_to [backer.project, backer]
  end

  def sitemap
    # TODO: update this sitemap to use new homepage logic
    @home_page    ||= Project.includes(:user, :category).visible.limit(6).all
    @expiring     ||= Project.includes(:user, :category).visible.expiring.not_expired.order("(projects.expires_at), created_at DESC").limit(3).all
    @recent       ||= Project.includes(:user, :category).visible.not_expiring.not_expired.where("projects.user_id <> 7329").order('created_at DESC').limit(3).all
    @successful   ||= Project.includes(:user, :category).visible.successful.order("(projects.expires_at) DESC").limit(3).all
    return render 'sitemap'
  end

end
