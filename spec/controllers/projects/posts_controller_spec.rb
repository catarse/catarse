# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::PostsController, type: :controller do
  let(:project_post) { create(:project_post) }
  let(:current_user) { nil }
  before { allow(controller).to receive(:current_user).and_return(current_user) }
  subject { response }

  describe 'DELETE destroy' do
    before { delete :destroy, params: { project_id: project_post.project.id, id: project_post.id, locale: 'pt' } }
    context 'When user is a guest' do
      it { is_expected.to have_http_status(302) }
    end

    context "When user is a registered user but don't the project owner" do
      let(:current_user) { create(:user) }
      it { is_expected.to have_http_status(302) }
      it { is_expected.to redirect_to root_path }
    end

    context 'When user is admin' do
      let(:current_user) { create(:user, admin: true) }
      it { is_expected.to have_http_status(302) }
      it { is_expected.to redirect_to posts_project_path(project_post.project) }
    end

    context 'When user is project_owner' do
      let(:current_user) { project_post.project.user }
      it { is_expected.to have_http_status(302) }
      it { is_expected.to redirect_to posts_project_path(project_post.project) }
    end
  end
end
