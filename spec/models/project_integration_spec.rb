# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectIntegration, type: :model do
  describe 'project.notify_reminder_of_publish' do
    let(:project) { create(:project, { name: 'Project name', state: 'draft' }) }
    let(:coming_soon) { create(:coming_soon_integration, { project: project }) }
    let(:project_reminder) { create(:project_reminder, { project: project })}

    it 'should have notifications created to subscribers' do
      reminders_count = project.reminders.length

      project.notify_reminder_of_publish

      expect(project.notifications.length).to eq(reminders_count)
      expect(project.reminders.length).to eq(0)
    end
  end

  describe 'ProjectIntegration.coming_soon' do
    let(:project) { create(:project, { name: 'Project name', state: 'draft' }) }
    let(:coming_soon) { create(:coming_soon_integration, { project: project }) }

    it 'should find project integration from coming_soon scope' do
      found = ProjectIntegration.coming_soon.find_by_id coming_soon.id

      expect(found.id).to eq(coming_soon.id)
    end
  end

  describe 'ProjectIntegration.by_draft_url' do
    let(:project) { create(:project, { name: 'Project name', state: 'draft' }) }
    let(:coming_soon) { create(:coming_soon_integration, { project: project }) }

    it 'should find project by draft url' do
      found = ProjectIntegration.by_draft_url(coming_soon.data['draft_url']).first

      expect(found.project.id).to eq(coming_soon.project.id)
    end
  end
end
