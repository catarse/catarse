class SurveyPolicy < ApplicationPolicy
  def show?
    user.admin? || User.who_chose_reward(record.reward.id).pluck(:id).include?(user.id)
  end

  def answer?
    show?
  end

  def new?
    done_by_owner_or_admin?
  end

end

