# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectIntegrationPolicy do
  subject { described_class }

  shared_examples_for 'deactivation' do
    it 'does not deactivate when user is not the owner nor admin' do
      coming_soon = ProjectIntegration.new(name: 'COMING_SOON_LANDING_PAGE', project: Project.new)
      expect(subject).not_to permit(User.new, coming_soon)
    end

    it 'deactivates when user is an admin' do
      admin = User.new
      admin.admin = true
      coming_soon = ProjectIntegration.new(name: 'COMING_SOON_LANDING_PAGE', project: Project.new)
      expect(subject).to permit(admin, coming_soon)
    end

    it 'deactivates when user is the owner of the project' do
      user = User.new
      project = Project.new(user: user)
      coming_soon = ProjectIntegration.new(name: 'COMING_SOON_LANDING_PAGE', project: project)
      expect(subject).to permit(user, coming_soon)
    end
  end

  permissions :deactivate? do
    it_behaves_like 'deactivation'
  end

  shared_examples_for 'activation' do
    it 'does not activates when the user is not the project owner nor admin' do
      project = Project.new
      coming_soon = ProjectIntegration.new(name: 'COMING_SOON_LANDING_PAGE', project: project)
      expect(subject).not_to permit(User.new, coming_soon)
    end

    it 'activates when the user is admin' do
      admin = User.new
      admin.admin = true
      coming_soon = ProjectIntegration.new(name: 'COMING_SOON_LANDING_PAGE', project: Project.new)
      expect(subject).to permit(admin, coming_soon)
    end

    it 'activates when user is the owner of the project' do
      user = User.new
      project = Project.new(user: user)
      coming_soon = ProjectIntegration.new(name: 'COMING_SOON_LANDING_PAGE', project: project)
      expect(subject).to permit(user, coming_soon)
    end
  end

  permissions :activate? do
    it_behaves_like 'activation'
  end
end
