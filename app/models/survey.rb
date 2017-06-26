class Survey < ActiveRecord::Base
  belongs_to :reward
  has_many :survey_open_questions
  has_many :survey_multiple_choice_questions
  accepts_nested_attributes_for :survey_open_questions, allow_destroy: true
  accepts_nested_attributes_for :survey_multiple_choice_questions, allow_destroy: true

end
