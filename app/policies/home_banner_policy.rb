class HomeBannerPolicy < ApplicationPolicy

    def update?
        is_admin?
    end
    
end