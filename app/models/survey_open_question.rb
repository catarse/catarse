class SurveyOpenQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_open_question_answers

end
