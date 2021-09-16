# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectFiscalPolicy do
  subject { described_class }

  shared_examples_for 'access permissions' do
    it 'denies access if user is nil' do
      expect(subject).not_to permit(nil, ProjectFiscal.new)
    end

    it 'denies access if user is not project_fiscal owner' do
      expect(subject).not_to permit(User.new, ProjectFiscal.new(user: User.new))
    end

    it 'permits access if user is project_fiscal owner' do
      new_user = User.new
      expect(subject).to permit(new_user, ProjectFiscal.new(user: new_user))
    end

    it 'permits access if user is admin' do
      admin = User.new
      admin.admin = true
      expect(subject).to permit(admin, ProjectFiscal.new(user: User.new))
    end
  end

  permissions(:debit_note?) { it_behaves_like 'access permissions' }

  permissions(:inform?) { it_behaves_like 'access permissions' }

  permissions(:inform_years?) { it_behaves_like 'access permissions' }

  permissions(:debit_note_end_dates?) { it_behaves_like 'access permissions' }
end
