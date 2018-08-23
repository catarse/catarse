# frozen_string_literal: true

class RewardPolicy < ApplicationPolicy
  def create?
    done_by_owner_or_admin?
  end

  def update?
    done_by_owner_or_admin?
  end

  def sort?
    done_by_owner_or_admin?
  end

  def toggle_survey_finish?
    done_by_owner_or_admin?
  end

  def destroy?
    done_by_owner_or_admin? && !record.any_sold?
  end

  def permitted_attributes
    attributes = record.attribute_names.map(&:to_sym)
    attributes << { shipping_fees_attributes: %i[_destroy id value destination] }
    unless user.try(:admin?)
      attributes.delete(:minimum_value) if record.persisted? && record.any_sold?
      attributes.delete(:deliver_at) if record.persisted? && project_finished?
    end
    attributes
  end

  protected

  def project_finished?
    record.project.failed? || record.project.successful?
  end

  def done_by_owner_or_admin?
    record.project.user == user || user.try(:admin?)
  end
end
