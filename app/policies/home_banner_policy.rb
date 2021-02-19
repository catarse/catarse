# frozen_string_literal: true

class HomeBannerPolicy < ApplicationPolicy

    def update?
        is_admin?
    end
    
end