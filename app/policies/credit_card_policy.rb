class CreditCardPolicy < ApplicationPolicy
  def destroy?
    done_by_owner_or_admin?
  end
end
