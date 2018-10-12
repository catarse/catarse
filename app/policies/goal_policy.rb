# frozen_string_literal: true

class GoalPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def destroy?
    done_by_owner_or_admin?
  end

  def permitted_attributes
    attributes = record.attribute_names.map(&:to_sym)
    attributes << { goals_attributes: [:id, :_destroy] }
  end

  protected

  def done_by_owner_or_admin?
    record.project.user == user || user.try(:admin?)
  end
end
