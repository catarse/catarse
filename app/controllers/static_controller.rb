class StaticController < ApplicationController

  def new_home
    render :layout => 'redesign'
  end

  def guidelines
    @title = t('static.guidelines.title')
  end

  def faq
    @title = t('static.faq.title')
  end

  def terms
    @title = t('static.terms.title')
  end

  def privacy
    @title = t('static.privacy.title')
  end
end