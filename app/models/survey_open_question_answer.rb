class SurveyOpenQuestionAnswer < ApplicationRecord
  belongs_to :survey_open_question
  belongs_to :contribution

end
