# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Projects::ContributionsController, type: :controller do
  let(:project) { create(:project) }
  let(:contribution) { create(:pending_contribution, value: 10.00, project: project) }
  let(:user) { nil }
  let(:contribution_info) { { address_city: 'Porto Alegre', address_complement: '24', address_neighbourhood: 'Rio Branco', address_number: '1004', phone_number: '(51)2112-8397', address_state: 'RS', address_street: 'Rua Mariante', address_zip_code: '90430-180', payer_email: 'diogo@biazus.me', payer_name: 'Diogo de Oliveira Biazus' } }

  subject { response }

  before do
    allow(PaymentEngines).to receive(:engines).and_return([])
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'PUT update' do
    let(:set_expectations) {}

    before do
      set_expectations
      put :update, params: {
        locale: :pt,
        project_id: project.id,
        id: contribution.id,
        contribution: contribution_info,
        format: :json
      }
    end

    context 'when no user is logged in' do
      it { is_expected.to redirect_to(new_user_registration_path) }
    end

    context "when contribution don't exist in current_user" do
      let(:user) { create(:user) }
      it { is_expected.to redirect_to(root_path) }
    end

    context 'when we have the right user' do
      let(:set_expectations) { expect_any_instance_of(Contribution).to receive(:update_user_billing_info) }
      let(:user) { contribution.user }
      it { is_expected.to be_successful }
    end

    context 'when try pass unpermitted attributes' do
      let(:contribution_info) { { payment_service_fee: 1000, value: 1000, address_city: 'Porto Alegre', address_complement: '24', address_neighbourhood: 'Rio Branco', address_number: '1004', address_phone_number: '(51)2112-8397', address_state: 'RS', address_street: 'Rua Mariante', address_zip_code: '90430-180', payer_email: 'diogo@biazus.me', payer_name: 'Diogo de Oliveira Biazus' } }

      it { is_expected.to be_redirect }
    end
  end

  describe 'GET edit' do
    before do
      request.env['REQUEST_URI'] = '/test_path'
      get :edit, params: { locale: :pt, project_id: project.id, id: contribution.id }
    end

    context 'when no user is logged' do
      it { is_expected.to redirect_to new_user_registration_path }
      it('should set the session[:return_to]') { expect(session[:return_to]).to eq('/test_path') }
    end

    context 'when user is logged in' do
      let(:user) { create(:user) }
      let(:contribution) { create(:contribution, value: 10.00, project: project, user: user) }
      it { is_expected.to render_template(:edit) }
    end

    context 'when contribution already has payment' do
      let(:user) { create(:user) }
      let(:contribution) { create(:pending_contribution, value: 10.00, project: project, user: user) }
      it { is_expected.to render_template(:existing_payment) }
    end

    context 'when reward is sold out' do
      before do
        allow_any_instance_of(Reward).to receive(:sold_out?).and_return(true)
      end
      it { is_expected.to be_redirect }
    end
  end

  describe 'POST create' do
    let(:value) { '20.00' }
    before do
      request.env['REQUEST_URI'] = '/test_path'
      post :create, params: {
        locale: :pt,
        project_id: project.id,
        contribution: { value: value, reward_id: nil, anonymous: '0' }
      }
    end

    context 'when no user is logged' do
      it { is_expected.to redirect_to new_user_registration_path }
      it('should set the session[:return_to]') { expect(session[:return_to]).to eq('/test_path') }
    end

    context 'when user is logged in' do
      let(:user) { create(:user) }
      let(:contribution) { Contribution.last }
      it { should redirect_to edit_project_contribution_path(project_id: project.id, id: contribution.id) }
      it 'should copy user data to newly created contribution' do
        expect(contribution.payer_name).to eq user.name
        expect(contribution.payer_email).to eq user.email
      end
    end

    context 'without value' do
      let(:user) { create(:user) }
      let(:value) { '' }

      it { is_expected.to render_template(:new) }
    end

    context 'with invalid contribution values' do
      let(:user) { create(:user) }
      let(:value) { '2' }

      it { is_expected.to render_template(:new) }
    end
  end

  describe 'GET new' do
    let(:secure_review_host) { nil }
    let(:user) { create(:user) }
    let(:open_for_contributions) { true }
    let(:browser) { Browser.new('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.29 Safari/537.36 Edg/79.0.309.18') }

    before do
      CatarseSettings[:secure_review_host] = secure_review_host
      allow_any_instance_of(Project).to receive(:open_for_contributions?).and_return(open_for_contributions)
      allow(controller).to receive(:browser).and_return(browser)
      allow_any_instance_of(ApplicationController).to receive(:detect_old_browsers).and_call_original
      get :new, params: { locale: :pt, project_id: project.id }
    end

    context 'when browser is IE 9' do
      let(:browser) { Browser.new('Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)') }
      it { is_expected.to redirect_to page_path('bad_browser') }
    end

    context 'when browser is old' do
      let(:browser) { Browser.new('Mozilla/5.0 (Linux; U; Android 2.3.3; en-us; Sensation_4G Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/5.0 Safari/533.16') }
      it { is_expected.to redirect_to page_path('bad_browser') }
    end

    context 'when no user is logged' do
      let(:user) { nil }
      it { is_expected.to render_template('projects/contributions/new') }
    end

    context 'when user is logged in but project.open_for_contributions?? is false' do
      let(:open_for_contributions) { false }
      it { is_expected.to redirect_to root_path }
    end

    context 'when project.open_for_contributions? is true' do
      it { is_expected.to render_template('projects/contributions/new') }
    end
  end

  describe 'GET show' do
    let(:contribution) { create(:confirmed_contribution, value: 10.00) }
    before do
      get :show, params: { locale: :pt, project_id: contribution.project.id, id: contribution.id }
    end

    context 'when no user is logged in' do
      it { is_expected.to redirect_to new_user_registration_path }
    end

    context 'when user logged in is different from contribution' do
      let(:user) { create(:user) }
      it { is_expected.to redirect_to root_path }
    end

    context 'when contribution is logged in' do
      let(:user) { contribution.user }

      it "has response successful" do
        expect(response.code.to_i).to eq(200)
      end
    end
  end
end
