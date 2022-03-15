# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ProjectFiscalController, type: :controller do
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET project_debit_note/:id' do
    context 'when project fiscal not exist' do
      before do
        get :debit_note, params: { project_id: project.id, id: '1' }
      end

      let(:project) { create(:project) }
      let(:user) {  project.user }

      it { is_expected.to redirect_to edit_project_path(project.id, locale: nil) }
    end

    context 'when project fiscal exist and user isn`t not project owner' do
      let(:project) { project_fiscal.project }
      let(:user) { build(:user) }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :debit_note, params: { project_id: project.id, id: project_fiscal.id }
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when project fiscal exist and user is admin' do
      let(:project) { project_fiscal.project }
      let(:user) { build(:user, admin: true) }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :debit_note, params: { project_id: project.id, id: project_fiscal.id }
      end

      it { is_expected.to render_template('user_notifier/mailer/project_fiscal_debit_note') }
    end

    context 'when project fiscal exist and user is project owner' do
      let(:project) { project_fiscal.project }
      let(:user) {  project_fiscal.user }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :debit_note, params: { project_id: project.id, id: project_fiscal.id }
      end

      it { is_expected.to render_template('user_notifier/mailer/project_fiscal_debit_note') }
    end
  end

  describe 'GET project_inform/:fiscal_year' do
    context 'when project fiscal not exist' do
      before do
        get :inform, params: { project_id: project.id, fiscal_year: '2021' }
      end

      let(:project) { create(:project) }
      let(:user) {  project.user }

      it { is_expected.to redirect_to edit_project_path(project.id, locale: nil) }
    end

    context 'when project fiscal exist and user isn`t not project owner' do
      let(:project) { project_fiscal.project }
      let(:user) { build(:user) }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :inform, params: { project_id: project.id, fiscal_year: project_fiscal.end_date.year.to_s }
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when project fiscal exist and user is admin' do
      let(:project) { project_fiscal.project }
      let(:user) { build(:user, admin: true) }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :inform, params: { project_id: project.id, fiscal_year: project_fiscal.end_date.year.to_s }
      end

      it { is_expected.to render_template('user_notifier/mailer/project_fiscal_inform') }
    end

    context 'when project fiscal exist and user is project owner' do
      let(:project) { project_fiscal.project }
      let(:user) {  project_fiscal.user }
      let!(:project_fiscal) do
        create(:project_fiscal, begin_date: '02/2020'.to_date.beginning_of_month,
          end_date: '02/2020'.to_date.end_of_month
        )
      end

      before do
        create(:project_fiscal, begin_date: (project_fiscal.begin_date - 1.month),
          end_date: (project_fiscal.end_date - 1.year)
        )
        create(:project_fiscal, begin_date: (project_fiscal.begin_date - 1.month),
          end_date: (project_fiscal.end_date - 1.month)
        )

        get :inform, params: { project_id: project.id, fiscal_year: project_fiscal.end_date.year.to_s }
      end

      it 'returns all project_fiscals' do
        expect(described_class).to render_template(
          'user_notifier/mailer/project_fiscal_inform',
          locals: { project_fiscals: ProjectFiscal.all },
          layout: 'layouts/email'
        )
      end
    end

    context 'when project fiscal is subscription and user is project owner' do
      let(:project) { project_fiscal.project }
      let(:user) {  project_fiscal.user }
      let!(:project_fiscal) do
        create(:project_fiscal, begin_date: '02/2020'.to_date.beginning_of_month,
          end_date: '02/2020'.to_date.end_of_month
        )
      end

      let!(:project_fiscal_1) do
        create(:project_fiscal, begin_date: (project_fiscal.begin_date - 1.month),
          end_date: (project_fiscal.end_date - 1.month)
        )
      end

      before do
        create(:project_fiscal, begin_date: (project_fiscal.begin_date - 1.month),
          end_date: (project_fiscal.end_date - 1.year)
        )
        get :inform, params: { project_id: project.id, fiscal_year: project_fiscal.end_date.year.to_s }
      end

      it 'returns all project_fiscals in the year' do
        expect(described_class).to render_template(
          'user_notifier/mailer/project_fiscal_inform',
          locals: { project_fiscals: ProjectFiscal.where(id: [project_fiscal.id, project_fiscal_1.id]) },
          layout: 'layouts/email'
        )
      end
    end
  end

  describe 'GET /inform_years' do
    context 'when project fiscal not exist' do
      before do
        get :inform_years, params: { project_id: project.id }
      end

      let(:project) { create(:project) }
      let(:user) {  project.user }

      it 'result null' do
        param = JSON.parse(response.body).with_indifferent_access
        expect(param['result']).to eq([])
      end
    end

    context 'when project fiscal exist and user isn`t not project owner' do
      let(:project) { project_fiscal.project }
      let(:user) { build(:user) }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :inform_years, params: { project_id: project.id }
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when project fiscal exist and user is admin' do
      let(:project) { create(:project) }
      let(:user) { build(:user, admin: true) }
      let!(:project_fiscal_2) do
        create(:project_fiscal, project: project, end_date: 1.year.from_now)
      end

      before do
        create(:project_fiscal, project: project)
        get :inform_years, params: { project_id: project.id }
      end

      it 'returns result' do
        param = JSON.parse(response.body).with_indifferent_access
        expect(param['result']).to eq([project_fiscal_2.end_date.strftime('%Y').to_i])
      end
    end

    context 'when project fiscal exist and user is project owner' do
      let(:project) { create(:project) }
      let(:user) { project.user }
      let!(:project_fiscal_2) do
        create(:project_fiscal, user: user, project: project, end_date: 1.year.from_now)
      end

      before do
        create(:project_fiscal, project: project, user: user)
        get :inform_years, params: { project_id: project.id }
      end

      it 'returns result' do
        param = JSON.parse(response.body).with_indifferent_access
        expect(param['result']).to eq([project_fiscal_2.end_date.strftime('%Y').to_i])
      end
    end
  end

  describe 'GET /debit_note_end_dates' do
    context 'when project fiscal not exist' do
      before do
        get :debit_note_end_dates, params: { project_id: project.id }
      end

      let(:project) { create(:project) }
      let(:user) { project.user }

      it 'result null' do
        param = JSON.parse(response.body).with_indifferent_access
        expect(param['result']).to eq([])
      end
    end

    context 'when project fiscal exist and user isn`t not project owner' do
      let(:project) { project_fiscal.project }
      let(:user) { build(:user) }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :debit_note_end_dates, params: { project_id: project.id }
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when project fiscal exist and user is admin' do
      let(:project) { project_fiscal.project }
      let(:user) { build(:user, admin: true) }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :debit_note_end_dates, params: { project_id: project.id }
      end

      it 'returns result' do
        param = JSON.parse(response.body).with_indifferent_access
        expect(param['result']).to eq([
                                        {
                                          'project_fiscal_id' => project_fiscal.id,
                                          'project_id' => project_fiscal.project_id,
                                          'end_date' => I18n.l(project_fiscal.end_date.to_date)
                                        }
                                      ]
                                     )
      end
    end

    context 'when project fiscal exist and user is project owner' do
      let(:project) { project_fiscal.project }
      let(:user) {  project_fiscal.user }
      let!(:project_fiscal) { create(:project_fiscal) }

      before do
        get :debit_note_end_dates, params: { project_id: project.id }
      end

      it 'returns result' do
        param = JSON.parse(response.body).with_indifferent_access
        expect(param['result']).to eq([
                                        {
                                          'project_fiscal_id' => project_fiscal.id,
                                          'project_id' => project_fiscal.project_id,
                                          'end_date' => I18n.l(project_fiscal.end_date.to_date)
                                        }
                                      ]
                                     )
      end
    end
  end
end
