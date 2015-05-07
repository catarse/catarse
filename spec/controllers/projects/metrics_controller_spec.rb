#encoding:utf-8
require 'rails_helper'

RSpec.describe Projects::MetricsController, type: :controller do
  before{ allow(controller).to receive(:current_user).and_return(current_user) }
  before{ CatarseSettings[:base_url] = 'http://catarse.me' }
  before{ CatarseSettings[:email_projects] = 'foo@bar.com' }
  render_views
  subject{ response }
  let(:project){ create(:project, state: 'online') }
  let(:current_user){ nil }

  describe "GET index" do
    before { get :index, project_id: project.id,  locale: :pt }

    context "without an authenticated user" do
      it { is_expected.to redirect_to sign_up_path }
    end

    context "with authenticated user" do
      let(:current_user) { create(:user) }
      it { is_expected.to redirect_to root_path }
    end

    context "authenticated with project owner user" do
      let(:current_user) { project.user }
      it { is_expected.to be_success }
    end

    context "with authenticated admin user" do
      let(:current_user) { create(:user, admin: true) }
      it { is_expected.to be_success }
    end
  end
end
