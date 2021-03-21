# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def access?
    is_admin?
  end

  def batch_chargeback?
    is_admin? && user.admin_roles.pluck(:role_label).include?('balance')
  end

  def refund_subscription_payment?
    is_admin? && user.admin_roles.pluck(:role_label).include?('refund_subscription')
  end
end
