# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ComingSoonController, type: :controller do
  context 'when activating' do
    describe 'on success' do
      let(:project) { create(:project, state: 'draft') }
      let(:current_user) { project.user }

      before do
        allow(controller).to receive(:current_user).and_return(current_user)
      end

      it 'activates coming soon landing page' do
        post :activate, params: { format: :json, id: project.id }

        expect(project.integrations[0].to_json).to eq(response.body)
      end
    end

    describe 'on error' do
      let(:project_without_headline) { create(:project, state: 'draft', headline: nil) }
      let(:current_user) { project_without_headline.user }

      before do
        allow(controller).to receive(:current_user).and_return(current_user)
      end

      it 'does not activate coming soon landing page without headline' do
        post :activate, params: { format: :json, id: project_without_headline.id }

        expect(JSON.parse(response.body).symbolize_keys).to include(:headline)
      end
    end
  end

  context 'when deactivating' do
    let(:project) { create(:project, state: 'draft') }
    let(:current_user) { project.user }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      post :activate, params: { format: :json, id: project.id }
    end

    it 'deactivates coming soon landing page and have 0 reminders' do
      delete :deactivate, params: { format: :json, id: project.id }
      expect(project.reminders.length).to eq(0)
    end
  end
end
