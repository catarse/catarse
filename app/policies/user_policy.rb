class UserPolicy < ApplicationPolicy
  def credits?
    done_by_onwer_or_admin?
  end

  def update?
    done_by_onwer_or_admin?
  end

  def update_password?
    done_by_onwer_or_admin?
  end

  def unsubscribe_notifications?
    done_by_onwer_or_admin?
  end

  protected
  def done_by_onwer_or_admin?
    record == user || user.try(:admin?)
  end
end

