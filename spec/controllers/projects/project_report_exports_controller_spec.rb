# encoding:utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ProjectReportExportsController, type: :controller do
  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  render_views
  subject { response }
  let(:project) { create(:project, state: 'draft') }
  let(:current_user) { nil }
  let(:create_params) { { report_type: 'SubscriptionMonthlyReportForProjectOwner', report_type_ext: 'csv'} }
  let(:before_lazy) { nil }

  describe 'GET show' do
    let(:report_export) { create(:project_report_export, project: project) }

    before do
      before_lazy
      get :show, { locale: :pt, project_id: project.id, id: report_export.id}
    end

    context 'when no user is logged in' do
      it { is_expected.to redirect_to new_user_registration_path }
    end

    context 'when user is logged in but not project owner' do
      let(:current_user) { create(:user) }
      it { is_expected.to redirect_to root_path }
    end

    context 'when user is logged and is admin and report is not done' do
      let(:before_lazy) do
        expect(controller).not_to receive(:send_data)
      end
      let(:current_user) { create(:user, admin: true) }
      it { expect(response.status).to eq(404) }
    end

    context 'when user is logged and is admin and report is done' do
      let(:before_lazy) do
        report_export.fetch_report
        expect(controller).to receive(:send_data)
      end
      let(:current_user) { create(:user, admin: true) }
      it { expect(response.status).to eq(200) }
    end

  end

  describe 'POST create' do
    before do
      post :create, { locale: :pt, project_id: project.id, project_report_export: create_params}
    end

    context 'when no user is logged in' do
      it { is_expected.to redirect_to new_user_registration_path }
    end

    context 'when user is logged in but not project owner' do
      let(:current_user) { create(:user) }
      it { is_expected.to redirect_to root_path }
    end

    context 'when user is logged and is admin' do
      let(:current_user) { create(:user, admin: true) }
      it { is_expected.to be_successful }
    end

    context 'when user is logged and is project_owner' do
      let(:current_user) { project.user }
      it { is_expected.to be_successful }
      it 'expect to create report exports' do
        json = ActiveSupport::JSON.decode(response.body)
        report = project.project_report_exports.find(json['id'])
        expect(report.present?).to eq(true)
      end
    end
  end
end
