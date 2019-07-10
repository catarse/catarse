# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProjectMetricStorageRefreshWorker do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:confirmed_contribution) { create(:confirmed_contribution, project_id: project.id, user_id: user.id) }
  let(:payment) { confirmed_contribution.payments.first }
  let!(:contact_user) { create(:user, email: CatarseSettings[:email_contact]) }

  before do
    Sidekiq::Testing.inline!
  end

  context 'when project is in draft' do
    let(:project) { create(:project, state: 'draft') }
    before do
      expect(Project).to receive(:find).with(project.id).and_return(project)
      expect(project).not_to receive(:refresh_project_metric_storage)
      expect(ProjectMetricStorageRefreshWorker).not_to receive(:perform_in).with(10.seconds, project.id)
    end
    it 'should not call refresh function' do
      ProjectMetricStorageRefreshWorker.perform_async(project.id)
    end
  end

  context 'when project is not subscription type' do
    let(:project) { create(:project, mode: 'flex', state: 'online') }
    before do
      expect(Project).to receive(:find).with(project.id).and_return(project)
      expect(project).to receive(:refresh_project_metric_storage)
      expect(ProjectMetricStorageRefreshWorker).not_to receive(:perform_in).with(10.seconds, project.id)
    end

    it 'should not reschedule a next run for metrics refresh' do
      ProjectMetricStorageRefreshWorker.perform_async(project.id)
    end
  end

  context 'when project is subscription type' do
    let(:project) { create(:subscription_project, state: 'online') }
    before do
      expect(Project).to receive(:find).with(project.id).and_return(project)
      expect(project).to receive(:refresh_project_metric_storage)
      expect(ProjectMetricStorageRefreshWorker).to receive(:perform_in).with(10.seconds, project.id)
    end

    it 'should reschedule a next run for metrics refresh' do
      ProjectMetricStorageRefreshWorker.perform_async(project.id)
    end
  end
end
