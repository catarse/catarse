class RewardPolicy < ApplicationPolicy
  def create?
    done_by_onwer_or_admin?
  end

  def update?
    done_by_onwer_or_admin?
  end

  def sort?
    done_by_onwer_or_admin?
  end

  def destroy?
    done_by_onwer_or_admin? && not_yet_sold?
  end

  def permitted_attributes
    attributes = record.attribute_names.map(&:to_sym)
    attributes.delete(:minimum_value) unless not_yet_sold?
    attributes.delete(:days_to_delivery) if project_finished?
    { reward: attributes }
  end

  protected
  def not_yet_sold?
    record.total_compromised == 0
  end

  def project_finished?
    record.project.failed? || record.project.successful?
  end

  def done_by_onwer_or_admin?
    record.project.user == user || user.try(:admin?)
  end
end

