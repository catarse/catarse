class ProjectAccountPolicy < ApplicationPolicy

  def create?
    can_modify?
  end

  def update?
    can_modify?
  end

  def permitted_attributes
    if can_modify?
      attributes = record.attribute_names.map(&:to_sym)
      { project_account: attributes }
    else
      { project_account: [] }
    end
  end

  protected

  def can_modify?
    done_by_owner_or_admin? && record.project.state != 'online'
  end

  def done_by_owner_or_admin?
    record.project.user == user || user.try(:admin?)
  end
end
