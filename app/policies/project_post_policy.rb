class ProjectPostPolicy < ApplicationPolicy

  self::Scope = Struct.new(:user, :scope) do

    def resolve
      project = scope.proxy_association.owner

      if user && (user.try(:admin) || user.project_ids.include?(project.id) || user.made_any_contribution_for_this_project?(project.id))
        scope.load
      else
        scope.for_non_contributors
      end
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

  def permitted_attributes
    if done_by_owner_or_admin?
      { project_post: [:title, :comment, :exclusive, :user_id] }
    else
      { project_post: [] }
    end
  end

  protected

  def done_by_owner_or_admin?
    record.project.user == user || user.try(:admin?)
  end
end
