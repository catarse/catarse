class UpdatePolicy < ApplicationPolicy

  def create?
    done_by_onwer_or_admin?
  end

  def update?
    done_by_onwer_or_admin?
  end

  def destroy?
    done_by_onwer_or_admin?
  end

  def permitted_attributes
    if done_by_onwer_or_admin?
      { update: [:title, :comment, :exclusive, :user_id] }
    else
      { update: [] }
    end
  end

  protected

  def done_by_onwer_or_admin?
    record.project.user == user || user.try(:admin?)
  end
end
