# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  def access?
    is_admin?
  end
end
