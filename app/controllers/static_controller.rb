class StaticController < ApplicationController
  def guidelines_tips
    @title = t('static.guidelines_tips.title')
  end

  def thank_you
    backer = Backer.find session[:thank_you_backer_id]
    redirect_to [backer.project, backer]
  end
end
