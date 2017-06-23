# frozen_string_literal: true

class AdminBalancePolicy < ApplicationPolicy
  def access?
    is_admin? && user.admin_roles.pluck(:role_label).include?('balance')
  end
end
