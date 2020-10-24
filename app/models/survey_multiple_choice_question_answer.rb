class SurveyMultipleChoiceQuestionAnswer < ApplicationRecord
  belongs_to :survey_multiple_choice_question
  belongs_to :survey_question_choice
  belongs_to :contribution

end
