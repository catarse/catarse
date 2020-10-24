# encoding:utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::IntegrationsController, type: :controller do

  let(:project_integration) { create(:project_integration) }
  let(:current_user) {  project_integration.project.user }

  describe 'GET index' do
    it 'should get all integrations' do
      get :index, params: { locale: :pt, project_id: project_integration.project.id }
      expect(response.status).to eq(200)
    end
  end

  describe 'POST integration' do

    let(:integration_new) do
      { :name => 'PIXEL', :data => '{"data":{"id":"123456789123456789"}}' }
    end

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      post :create, params: {
        format: :json,
        locale: :pt,
        project_id: project_integration.project.id,
        integration: integration_new
      }
    end

    it 'should create new integration' do
      expect(response.status).to eq(200)
    end
  end

  describe 'UPDATE integration' do
    let(:integration_update) do
      { :id => project_integration.id, :name => 'GA', :data => '{"data":{"id":"UA-987654321"}}' }
    end

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      put :update, params: {
        format: :json,
        locale: :pt,
        project_id: project_integration.project.id,
        id: project_integration.id,
        integration: integration_update
      }
    end

    it 'should update integration' do
      expect(response.status).to eq(200)
    end
  end
end
