# frozen_string_literal: true

class SurveyPolicy < ApplicationPolicy
  def show?
    user.try(:admin?) || User.who_chose_reward(record.reward.id).pluck(:id).include?(user.try(:id))
  end

  def answer?
    show?
  end

  def create?
    new?
  end

  def new?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    [:reward_id, :confirm_address, :contribution_id,
     survey_multiple_choice_question_answers_attributes: %i[id contribution_id survey_question_choice_id survey_multiple_choice_question_id],
     survey_open_question_answers_attributes: %i[id survey_open_question_id contribution_id answer], 
     survey_open_questions_attributes: %i[id question description], 
     survey_multiple_choice_questions_attributes: [:id, :question, :description, survey_question_choices_attributes: %i[option survey_multiple_choice_question_id]],
     survey_address_answers_attributes: { addresses_attributes: %i[id country_id state_id address_street address_city address_neighbourhood address_number address_complement address_zip_code address_state phone_number] }].flatten
  end

  protected

  def done_by_owner_or_admin?
    record.reward.project.user == user || user.try(:admin?)
  end
end
