# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ProjectsController, type: :controller do
  subject { response }
  let(:admin) { create(:user, admin: true) }
  let(:current_user) { admin }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    request.env['HTTP_REFERER'] = admin_projects_path
  end

  describe 'PUT revert_or_finish' do
    let(:project) do
      sub = create(:subscription_project)
      sub.push_to_online
      sub
    end

    context 'when project is not sub' do
      let(:project) { create(:project, state: 'online', mode: 'flex') }
      before do
        put :revert_or_finish, params: { id: project.id, locale: :pt }
      end
      it { expect(response.code).to eq("404") }
    end

    context 'when project have active or started subscriptions' do
      before do
        allow(SubscriptionProject).to receive(:find).and_return(project)
        allow(project).to receive_message_chain(:subscriptions, :active_and_started, :exists?).and_return(true)
        allow(project).to receive(:common_finish!).and_return(true)

        expect(project).to receive(:finish).and_call_original
        expect(project).to receive(:common_finish!)

        put :revert_or_finish, params: { id: project.id, locale: :pt }
        project.reload
      end
      it { expect(response.code).to eq("200") }
      it { expect(project.state).to eq("successful") }
    end

    context 'when project does not have any subscription' do
      before do
        allow(SubscriptionProject).to receive(:find).and_return(project)
        allow(project).to receive_message_chain(:subscriptions, :active_and_started, :exists?).and_return(false)
        allow(project).to receive(:common_finish!).and_return(true)

        expect(project).to_not receive(:finish).and_call_original
        expect(project).to_not receive(:common_finish!)

        put :revert_or_finish, params: { id: project.id, locale: :pt }
        project.reload
      end
      it { expect(response.code).to eq("200") }
      it { expect(project.state).to eq("draft") }
    end

  end

  describe 'PUT reject' do
    let(:project) { create(:project, state: 'draft') }
    subject { project.rejected? }

    before do
      put :reject, params: { id: project, locale: :pt }
      project.reload
    end

    it { is_expected.to eq(true) }
  end

  describe 'PUT push_to_draft' do
    let(:project) { create(:project, state: 'rejected') }
    subject { project.draft? }

    before do
      allow(controller).to receive(:current_user).and_return(admin)
      put :push_to_draft, params: { id: project, locale: :pt }
    end

    it do
      project.reload
      is_expected.to eq(true)
    end
  end

  describe 'PUT push_to_trash' do
    let(:project) { create(:project, state: 'draft') }
    subject { project.reload.deleted? }

    before do
      allow(controller).to receive(:current_user).and_return(admin)
      put :push_to_trash, params: { id: project, locale: :pt }
    end

    it { is_expected.to eq(true) }
  end

  describe 'GET index' do
    context "when I'm not logged in" do
      let(:current_user) { nil }
      before do
        get :index, params: { locale: :pt }
      end
      it { is_expected.to redirect_to new_user_registration_path }
    end

    context "when I'm logged as admin" do
      before do
        get :index, params: { locale: :pt }
      end
      it { is_expected.to have_http_status(200) }
    end
  end

  describe '.collection' do
    let(:project) { create(:project, name: 'Project for search') }
    context 'when there is a match' do
      before do
        get :index, params: { locale: :pt, pg_search: 'Project for search' }
      end
      it { expect(assigns(:projects)).to eq([project]) }
    end

    context 'when there is no match' do
      before do
        get :index, params: { locale: :pt, pg_search: 'Foo Bar' }
      end
      it { expect(assigns(:projects)).to eq([]) }
    end
  end

  describe 'DELETE destroy' do
    let(:project) { create(:project, state: 'draft') }

    context "when I'm not logged in" do
      let(:current_user) { nil }
      before do
        delete :destroy, params: { id: project, locale: :pt }
      end
      it { is_expected.to redirect_to new_user_registration_path }
    end

    context "when I'm logged as admin" do
      before do
        delete :destroy, params: { id: project, locale: :pt }
      end

      it { is_expected.to redirect_to(admin_projects_path) }

      it 'should change state to deleted' do
        expect(project.reload.deleted?).to eq(true)
      end
    end
  end
end
