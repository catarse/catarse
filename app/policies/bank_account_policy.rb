class BankAccountPolicy < ApplicationPolicy
  def edit?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    [:bank_id, :name, :agency, :account, :owner_name, :owner_document, :account_digit, :agency_digit]
  end

  protected
  def done_by_owner_or_admin?
    record == user || user.try(:admin?)
  end
end


