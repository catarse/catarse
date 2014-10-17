class UserPolicy < ApplicationPolicy
  def destroy?
    done_by_owner_or_admin?
  end

  def credits?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def update_password?
    done_by_owner_or_admin?
  end

  def unsubscribe_notifications?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    u_attrs = [ bank_account_attributes: [:bank_id, :name, :agency, :account, :owner_name, :owner_document, :account_digit, :agency_digit] ]
    u_attrs << record.attribute_names.map(&:to_sym)

    { user: u_attrs.flatten }
  end

  protected
  def done_by_owner_or_admin?
    record == user || user.try(:admin?)
  end
end

