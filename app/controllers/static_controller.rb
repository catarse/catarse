class StaticController < ApplicationController
  def guidelines_tips
    @title = t('static.guidelines_tips.title')
  end

  def thank_you
    contribution = Contribution.find session[:thank_you_contribution_id]
    redirect_to [contribution.project, contribution]
  end
end
