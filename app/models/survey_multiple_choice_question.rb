class SurveyMultipleChoiceQuestion < ActiveRecord::Base
  belongs_to :survey
  has_many :survey_multiple_choice_question_answers
  has_many :survey_question_choices
  accepts_nested_attributes_for :survey_question_choices, allow_destroy: true

end
