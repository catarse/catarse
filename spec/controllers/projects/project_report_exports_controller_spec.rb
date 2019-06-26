# encoding:utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ProjectReportExportsController, type: :controller do
  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    request.env['HTTP_REFERER'] = 'https://catarse.me'
    CatarseSettings[:base_url] = 'http://catarse.me'
    CatarseSettings[:email_projects] = 'foo@bar.com'
  end

  render_views
  subject { response }
  let(:project) { create(:project, state: 'draft') }
  let(:current_user) { nil }

  describe 'POST create' do
    let(:project) { build(:project, state: 'draft') }
    before do
      post :create, { locale: :pt, project: project.attributes }
    end

    context 'when no user is logged in' do
      it { is_expected.to redirect_to new_user_registration_path }
    end

    context 'when user is logged in' do
      let(:current_user) { create(:user, current_sign_in_ip: '127.0.0.1') }
      it { is_expected.to redirect_to insights_project_path(Project.last, locale: '') }
      it 'should fill with the current_sign_in_ip of user' do
        expect(Project.last.ip_address).to eq(current_user.current_sign_in_ip)
      end
    end
  end
end
