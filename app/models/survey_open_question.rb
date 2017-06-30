class SurveyOpenQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_open_question_answers
  accepts_nested_attributes_for :survey_open_question_answers, allow_destroy: true

end
