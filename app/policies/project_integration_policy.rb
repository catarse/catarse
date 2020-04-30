class ProjectIntegrationPolicy < ApplicationPolicy

    def create?
        done_by_owner_or_admin?
    end

    def update?
        done_by_owner_or_admin?
    end

    def destroy?
        is_admin?
    end
    
    protected

    def done_by_owner_or_admin?
      record.project.user == user || user.try(:admin?)
    end
end