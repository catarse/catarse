class SurveyPolicy < ApplicationPolicy
  def show?
    user.admin? || User.who_chose_reward(record.reward.id).pluck(:id).include?(user.id)
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
    [:reward_id, :confirm_address, survey_open_questions_attributes: [:id, :question, :description], survey_multiple_choice_questions_attributes: [:id, :question, :description, survey_question_choices_attributes: [:option, :survey_multiple_choice_question_id]], survey_address_answer: {address_attributes: [:id,:country_id, :state_id, :address_street, :address_city, :address_neighbourhood, :address_number, :address_complement, :address_zip_code, :phone_number ]}].flatten
  end

  protected

  def done_by_owner_or_admin?
    record.reward.project.user == user || user.try(:admin?)
  end

end

