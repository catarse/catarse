class Survey < ActiveRecord::Base
  has_notifications

  belongs_to :reward
  has_many :survey_open_questions
  has_many :survey_open_question_answers, through: :survey_open_questions
  has_many :survey_multiple_choice_questions
  has_many :survey_multiple_choice_question_answers, through: :survey_multiple_choice_questions
  accepts_nested_attributes_for :survey_open_questions, allow_destroy: true
  accepts_nested_attributes_for :survey_multiple_choice_questions, allow_destroy: true
  accepts_nested_attributes_for :survey_open_question_answers, allow_destroy: true
  accepts_nested_attributes_for :survey_multiple_choice_question_answers, allow_destroy: true

  def notify_to_contributors(template_name, options = {})
    reward.contributions.was_confirmed.each do |contribution|
      contribution.notify(template_name, contribution.user, contribution, options)
    end
  end
end
