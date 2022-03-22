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
    end

    it 'does not call refresh function' do
      described_class.perform_async(project.id)
    end
  end

  context 'when project is in draft and has comming soon landing page' do
    let(:project) { create(:project, state: 'draft') }

    before do
      create(:coming_soon_integration, { project: project })
      expect(Project).to receive(:find).with(project.id).and_return(project)
      expect(project).to receive(:refresh_project_metric_storage)
    end

    it 'calls refresh_project_metric_storage' do
      described_class.perform_async(project.id)
    end
  end

  context 'when project is in deleted' do
    let(:project) { create(:project, state: 'deleted') }

    before do
      expect(Project).to receive(:find).with(project.id).and_return(project)
      expect(project).not_to receive(:refresh_project_metric_storage)
    end

    it 'does not call refresh function' do
      described_class.perform_async(project.id)
    end
  end

  context 'when project can be processed' do
    let(:project) { create(:subscription_project, state: 'online') }

    before do
      expect(Project).to receive(:find).with(project.id).and_return(project)
      expect(project).to receive(:refresh_project_metric_storage)
    end

    it 'calls refresh_project_metric_storage' do
      described_class.perform_async(project.id)
    end
  end
end
