class SurveyOpenQuestionAnswer < ActiveRecord::Base
  belongs_to :survey_open_question
  belongs_to :contribution

end
