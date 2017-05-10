class Survey < ActiveRecord::Base
  belongs_to :reward
  has_many :survey_open_questions

end
