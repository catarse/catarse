class ContributionPolicy < ApplicationPolicy
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

