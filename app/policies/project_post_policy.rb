class ProjectPostPolicy < ApplicationPolicy

  self::Scope = Struct.new(:user, :scope) do

    def resolve
      scope
    end

  end

  def create?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def destroy?
    done_by_owner_or_admin?
  end

  def show?
    !record.exclusive || (user && visible_to_user)
  end

  def permitted_attributes
    if done_by_owner_or_admin?
      [:title, :comment_html, :exclusive, :user_id]
    else
      []
    end
  end

  protected

  def visible_to_user
    user.try(:admin) || user.project_ids.include?(record.project.id) || user.made_any_contribution_for_this_project?(record.project.id)
  end

  def done_by_owner_or_admin?
    record.project.user == user || user.try(:admin?)
  end
end
