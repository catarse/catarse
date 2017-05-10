class SurveyQuestionChoice < ActiveRecord::Base
  belongs_to :survey_multiple_choice_question
  has_many :survey_multiple_choice_question_answers

end
