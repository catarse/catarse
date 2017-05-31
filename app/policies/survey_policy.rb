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

  def permitted_attributes
    [{address_attributes: [:id,:country_id, :state_id, :address_street, :address_city, :address_neighbourhood, :address_number, :address_complement, :address_zip_code, :phone_number ]}].flatten
  end

end

