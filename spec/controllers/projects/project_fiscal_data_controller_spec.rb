# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ProjectFiscalDataController, type: :controller do
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET /inform' do
    context 'when inform not exist' do
      before do
        get :inform, params: { project_id: project.id, fiscal_year: project.created_at.year.to_s }
      end

      let(:project) { create(:project) }
      let(:user) {  project.user }

      it { is_expected.to redirect_to edit_project_path(project.id, locale: nil) }
    end

    context 'when inform exist and user isn`t not project owner' do
      let(:project) { create(:project) }
      let(:user) { create(:user) }
      let(:inform) { ProjectFiscalInform.new(user_id: project.user_id, project_id: project.id) }

      before do
        allow(ProjectFiscalInform).to receive(:find_by).with(
          project_id: project.id.to_s, fiscal_year: project.created_at.year.to_s
        ).and_return(inform)
        get :inform, params: { project_id: project.id, fiscal_year: project.created_at.year.to_s }
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when inform exist and user is admin' do
      let(:project) { create(:project) }
      let(:user) { build(:user, admin: true) }
      let(:inform) { ProjectFiscalInform.new(user_id: project.user_id, project_id: project.id) }

      before do
        allow(ProjectFiscalInform).to receive(:find_by).with(
          project_id: project.id.to_s, fiscal_year: project.created_at.year.to_s
        ).and_return(inform)
        get :inform, params: { project_id: project.id, fiscal_year: project.created_at.year.to_s }
      end

      it { is_expected.to render_template('user_notifier/mailer/project_inform') }
    end

    context 'when inform and user is project owner' do
      let(:project) { create(:project) }
      let(:user) {  project.user }
      let(:inform) { ProjectFiscalInform.new(user_id: project.user_id, project_id: project.id) }

      before do
        allow(ProjectFiscalInform).to receive(:find_by).with(
          project_id: project.id.to_s, fiscal_year: project.created_at.year.to_s
        ).and_return(inform)
        get :inform, params: { project_id: project.id, fiscal_year: project.created_at.year.to_s }
      end

      it { is_expected.to render_template('user_notifier/mailer/project_inform') }
    end
  end
end
