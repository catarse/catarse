# frozen_string_literal: true

class SurveyObserver < ActiveRecord::Observer
  observe :survey

  def after_create(survey)
    survey.notify_to_contributors(:answer_survey)
    survey.update_attribute(:sent_at, Time.current)
  end

end
