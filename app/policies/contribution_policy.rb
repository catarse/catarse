class ContributionPolicy < ApplicationPolicy

  self::Scope = Struct.new(:user, :scope) do

    def resolve
      if user.try(:admin?) 
        scope.available_to_display
      else
        scope.not_anonymous.with_state('confirmed')
      end
    end
  end

  def update?
    done_by_onwer_or_admin?
  end

  def show?
    done_by_onwer_or_admin?
  end
  
  def credits_checkout?
    done_by_onwer_or_admin?
  end

  def request_refund?
    done_by_onwer_or_admin?
  end
end

