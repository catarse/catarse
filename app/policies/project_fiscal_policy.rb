# frozen_string_literal: true

class ProjectFiscalPolicy < ApplicationPolicy
  def debit_note?
    done_by_owner_or_admin?
  end

  def inform?
    done_by_owner_or_admin?
  end

  def inform_years?
    done_by_owner_or_admin?
  end

  def debit_note_end_dates?
    done_by_owner_or_admin?
  end
end
