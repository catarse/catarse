require 'rails_helper'

RSpec.describe Projects::ContributionsController, type: :controller do
  let(:project) { create(:project) }
  let(:contribution){ create(:pending_contribution, value: 10.00, project: project) }
  let(:user){ nil }
  let(:contribution_info){ { address_city: 'Porto Alegre', address_complement: '24', address_neighbourhood: 'Rio Branco', address_number: '1004', address_phone_number: '(51)2112-8397', address_state: 'RS', address_street: 'Rua Mariante', address_zip_code: '90430-180', payer_email: 'diogo@biazus.me', payer_name: 'Diogo de Oliveira Biazus' } }

  subject{ response }

  before do
    allow(PaymentEngines).to receive(:engines).and_return([])
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "PUT update" do
    let(:set_expectations) {}

    before do
      set_expectations
      put :update, { locale: :pt, project_id: project.id, id: contribution.id, contribution: contribution_info, format: :json }
    end

    context "when no user is logged in" do
      it{ is_expected.to redirect_to(new_user_registration_path) }
    end

    context "when contribution don't exist in current_user" do
      let(:user){ create(:user) }
      it{ is_expected.to redirect_to(root_path) }
      it('should set flash failure'){ expect(request.flash[:alert]).not_to be_empty }
    end

    context "when we have the right user" do
      let(:set_expectations) { expect_any_instance_of(Contribution).to receive(:update_user_billing_info) }
      let(:user){ contribution.user }
      it{ is_expected.to be_successful }
    end

    context "when try pass unpermitted attributes" do
      let(:contribution_info) { { payment_service_fee: 1000, value: 1000,  address_city: 'Porto Alegre', address_complement: '24', address_neighbourhood: 'Rio Branco', address_number: '1004', address_phone_number: '(51)2112-8397', address_state: 'RS', address_street: 'Rua Mariante', address_zip_code: '90430-180', payer_email: 'diogo@biazus.me', payer_name: 'Diogo de Oliveira Biazus'  } }

      it { is_expected.to be_redirect }
    end
  end

  describe "GET edit" do
    before do
      request.env['REQUEST_URI'] = "/test_path"
      get :edit, {locale: :pt, project_id: project.id, id: contribution.id}
    end

    context "when no user is logged" do
      it{ is_expected.to redirect_to new_user_registration_path }
      it('should set the session[:return_to]'){ expect(session[:return_to]).to eq("/test_path") }
    end

    context "when user is logged in" do
      let(:user){ create(:user) }
      let(:contribution){ create(:pending_contribution, value: 10.00, project: project, user: user) }
      it{ is_expected.to render_template(:edit) }
    end

    context "when reward is sold out" do
      before do
        allow_any_instance_of(Reward).to receive(:sold_out?).and_return(true)
      end
      it { is_expected.to be_redirect }
    end
  end

  describe "POST create" do
    let(:value){ '20.00' }
    before do
      request.env['REQUEST_URI'] = "/test_path"
      post :create, {locale: :pt, project_id: project.id, contribution: { value: value, reward_id: nil, anonymous: '0' }}
    end

    context "when no user is logged" do
      it{ is_expected.to redirect_to new_user_registration_path }
      it('should set the session[:return_to]'){ expect(session[:return_to]).to eq("/test_path") }
    end

    context "when user is logged in" do
      let(:user){ create(:user) }
      let(:contribution){ Contribution.last }
      it{ should redirect_to edit_project_contribution_path(project_id: project.id, id: contribution.id) }
      it "should copy user data to newly created contribution" do
        expect(contribution.payer_name).to eq user.display_name
        expect(contribution.payer_email).to eq user.email
      end
    end

    context "without value" do
      let(:user){ create(:user) }
      let(:value){ '' }

      it{ is_expected.to render_template(:new) }
    end

    context "with invalid contribution values" do
      let(:user){ create(:user) }
      let(:value) { "2" }

      it{ is_expected.to render_template(:new) }
    end
  end

  describe "GET new" do
    let(:secure_review_host){ nil }
    let(:user){ create(:user) }
    let(:online){ true }
    let(:browser){ double("browser", ie9?: false, modern?: true, mobile?: false) }

    before do
      CatarseSettings[:secure_review_host] = secure_review_host
      allow_any_instance_of(Project).to receive(:online?).and_return(online)
      allow(controller).to receive(:browser).and_return(browser)
      allow_any_instance_of(ApplicationController).to receive(:detect_old_browsers).and_call_original
      get :new, {locale: :pt, project_id: project.id}
    end

    context "when browser is IE 9" do
      let(:browser){ double("browser", ie9?: true, modern?: true) }
      it{ is_expected.to redirect_to page_path("bad_browser") }
    end

    context "when browser is old" do
      let(:browser){ double("browser", ie9?: false, modern?: false) }
      it{ is_expected.to redirect_to page_path("bad_browser") }
    end

    context "when no user is logged" do
      let(:user){ nil }
      it{ is_expected.to render_template("projects/contributions/new") }
    end

    context "when user is logged in but project.online? is false" do
      let(:online){ false }
      it{ is_expected.to redirect_to root_path }
    end

    context "when project.online? is true" do
      it{ is_expected.to render_template("projects/contributions/new") }
    end
  end

  describe "GET show" do
    let(:contribution){ create(:confirmed_contribution, value: 10.00) }
    before do
      get :show, { locale: :pt, project_id: contribution.project.id, id: contribution.id }
    end

    context "when no user is logged in" do
      it{ is_expected.to redirect_to new_user_registration_path }
    end

    context "when user logged in is different from contribution" do
      let(:user){ create(:user) }
      it{ is_expected.to redirect_to root_path }
      it('should set flash failure'){ expect(request.flash[:alert]).not_to be_empty }
    end

    context "when contribution is logged in" do
      let(:user){ contribution.user }
      it{ is_expected.to be_successful }
    end
  end

  describe "GET index" do
    before do
      create(:confirmed_contribution, value: 10.00,
              reward: create(:reward, project: project, description: 'Test Reward'),
              project: project,
              user: create(:user, name: 'Foo Bar'))
      get :index, { locale: :pt, project_id: project.id }
    end
    its(:status){ should eq 200 }
  end
end
