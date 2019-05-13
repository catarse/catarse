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

  context 'when project have status' do
    context 'waiting_funds' do
      let(:project) { create(:project, state: 'waiting_funds') }
      before do
        expect(Project).to receive(:find).with(project.id).and_return(project)
        expect(project).to receive(:refresh_project_metric_storage)
        expect(ProjectMetricStorageRefreshWorker).to receive(:perform_in).with(10.seconds, project.id)
      end

      it { ProjectMetricStorageRefreshWorker.perform_async(project.id)}
    end

    context 'online' do
      let(:project) { create(:project, state: 'online') }
      before do
        expect(Project).to receive(:find).with(project.id).and_return(project)
        expect(project).to receive(:refresh_project_metric_storage)
        expect(ProjectMetricStorageRefreshWorker).to receive(:perform_in).with(10.seconds, project.id)
      end

      it { ProjectMetricStorageRefreshWorker.perform_async(project.id)}
    end

    context 'successful' do
      let(:project) { create(:project, state: 'successful') }
      before do
        expect(Project).to receive(:find).with(project.id).and_return(project)
        expect(project).to receive(:refresh_project_metric_storage)
        expect(ProjectMetricStorageRefreshWorker).not_to receive(:perform_in).with(10.seconds, project.id)
      end

      it { ProjectMetricStorageRefreshWorker.perform_async(project.id)}
    end

    context 'failed' do
      let(:project) { create(:project, state: 'failed') }
      before do
        expect(Project).to receive(:find).with(project.id).and_return(project)
        expect(project).to receive(:refresh_project_metric_storage)
        expect(ProjectMetricStorageRefreshWorker).not_to receive(:perform_in).with(10.seconds, project.id)
      end

      it { ProjectMetricStorageRefreshWorker.perform_async(project.id)}
    end
    context 'rejected' do
      let(:project) { create(:project, state: 'rejected') }
      before do
        expect(Project).to receive(:find).with(project.id).and_return(project)
        expect(project).to receive(:refresh_project_metric_storage)
        expect(ProjectMetricStorageRefreshWorker).not_to receive(:perform_in).with(10.seconds, project.id)
      end

      it { ProjectMetricStorageRefreshWorker.perform_async(project.id)}
    end

    context 'deleted' do
      let(:project) { create(:project, state: 'deleted') }
      before do
        expect(Project).to receive(:find).with(project.id).and_return(project)
        expect(project).not_to receive(:refresh_project_metric_storage)
        expect(ProjectMetricStorageRefreshWorker).not_to receive(:perform_in).with(10.seconds, project.id)
      end

      it { ProjectMetricStorageRefreshWorker.perform_async(project.id)}
    end

    context 'draft' do
      let(:project) { create(:project, state: 'draft') }

      before do
        expect(Project).to receive(:find).with(project.id).and_return(project)
        expect(project).not_to receive(:refresh_project_metric_storage)
        expect(ProjectMetricStorageRefreshWorker).not_to receive(:perform_in).with(10.seconds, project.id)
      end

      it { ProjectMetricStorageRefreshWorker.perform_async(project.id)}
    end
  end
end
