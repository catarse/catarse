class SurveyMultipleChoiceQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_multiple_choice_question_answers
  has_many :survey_question_choices

end
