# frozen_string_literal: true

class ProjectFiscalInformPolicy < ApplicationPolicy
  def inform?
    done_by_owner_or_admin?
  end
end
