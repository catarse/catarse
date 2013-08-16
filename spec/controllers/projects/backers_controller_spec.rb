require 'spec_helper'

describe Projects::BackersController do
  render_views
  let(:project) { create(:project) }
  let(:backer){ create(:backer, value: 10.00, credits: true, project: project, state: 'pending') }
  let(:user){ nil }
  let(:backer_info){ { address_city: 'Porto Alegre', address_complement: '24', address_neighbourhood: 'Rio Branco', address_number: '1004', address_phone_number: '(51)2112-8397', address_state: 'RS', address_street: 'Rua Mariante', address_zip_code: '90430-180', payer_email: 'diogo@biazus.me', payer_name: 'Diogo de Oliveira Biazus' } }

  subject{ response }

  before do
    controller.stub(:current_user).and_return(user)
  end

  describe "POST update_info" do
    before do
      post :update_info, { locale: :pt, project_id: project.id, id: backer.id, backer: backer_info }
    end

    context "when no user is logged in" do
      it{ should redirect_to(new_user_registration_path) }
    end

    context "when backer don't exist in current_user" do
      let(:user){ create(:user) }
      it{ should redirect_to(root_path) }
      it('should set flash failure'){ request.flash[:alert].should_not be_empty }
    end
    context "when we have the right user" do
      let(:user){ backer.user }
      its(:body){ should == { message: "updated" }.to_json  }
    end
  end

  describe "PUT credits_checkout" do
    let(:failed_project) { create(:project, state: 'online') }
    before do
      put :credits_checkout, { locale: :pt, project_id: project.id, id: backer.id }
    end

    context "without user" do
      it{ should redirect_to(new_user_registration_path) }
    end

    context "when backer don't exist in current_user" do
      let(:user){ create(:user) }
      it{ should redirect_to(root_path) }
      it('should set flash failure'){ request.flash[:alert].should_not be_empty }
    end

    context "with correct user but insufficient credits" do
      let(:user){ backer.user }
      it('should not confirm backer'){ backer.reload.confirmed?.should be_false }
      it('should set flash failure'){ request.flash[:failure].should == I18n.t('projects.backers.checkout.no_credits') }
      it{ should redirect_to(new_project_backer_path(project)) }
    end

    context "with correct user and sufficient credits" do
      let(:user) do
        create(:backer, value: 10.00, credits: false, state: 'confirmed', user: backer.user, project: failed_project)
        failed_project.update_attributes state: 'failed'
        backer.user.reload
        backer.user
      end

      it('should confirm backer'){ backer.reload.confirmed?.should be_true }
      it('should set flash success'){ request.flash[:success].should == I18n.t('projects.backers.checkout.success') }
      it{ should redirect_to(project_backer_path(project_id: project.id, id: backer.id)) }
    end
  end

  describe "POST create" do
    before do
      request.env['REQUEST_URI'] = "/test_path"
      post :create, {locale: :pt, project_id: project.id, backer: { value: '20.00', reward_id: nil, anonymous: '0' }}
    end

    context "when no user is logged" do
      it{ should redirect_to new_user_registration_path }
      it('should set the session[:return_to]'){ session[:return_to].should == "/test_path" }
    end

    context "when user is logged in" do
      let(:user){ create(:user) }
      its(:body){ should =~ /#{I18n.t('projects.backers.create.title')}/ }
      its(:body){ should =~ /#{project.name}/ }
      its(:body){ should =~ /R\$ 20/ }
    end

    context "with invalid backer values" do
      let(:user){ create(:user) }
      let(:errors){ e = ActiveModel::Errors.new(Backer.new); e.add(:value, 'is wrong'); e }

      before do
        Backer.any_instance.stub(:errors).and_return(errors)
        post :create, {locale: :pt, project_id: project.id, backer: { value: '20.00', reward_id: '0', anonymous: '0' }}
      end

      it{ should redirect_to new_project_backer_path(project) }
    end
  end

  describe "GET new" do
    let(:secure_review_host){ nil }
    let(:user){ create(:user) }
    let(:online){ true }
    before do
      ::Configuration[:secure_review_host] = secure_review_host
      Project.any_instance.stub(:online?).and_return(online)
      get :new, {locale: :pt, project_id: project.id}
    end

    context "when no user is logged" do
      let(:user){ nil }
      it{ should redirect_to new_user_registration_path }
    end

    context "when user is logged in but project.online? is false" do
      let(:online){ false }
      it{ should redirect_to root_path }
    end

    context "when project.online? is true and we have configured a secure create url" do
      let(:secure_review_host){ 'secure.catarse.me' }
      it "should assign the https url to @create_url" do
        assigns(:create_url).should == project_backers_url(project, host: ::Configuration[:secure_review_host], protocol: 'https')
      end
    end

    context "when project.online? is true and we have not configured a secure create url" do
      it{ should render_template("projects/backers/new") }
      it "should assign review_project_backers_path to @create_url" do
        assigns(:create_url).should == project_backers_path(project)
      end
      its(:body) { should =~ /#{I18n.t('projects.backers.new.header.title')}/ }
      its(:body) { should =~ /#{I18n.t('projects.backers.new.submit')}/ }
      its(:body) { should =~ /#{I18n.t('projects.backers.new.no_reward')}/ }
      its(:body) { should =~ /#{project.name}/ }
    end
  end

  describe "GET show" do
    let(:backer){ create(:backer, value: 10.00, credits: false, state: 'confirmed') }
    before do
      get :show, { locale: :pt, project_id: backer.project.id, id: backer.id }
    end

    context "when no user is logged in" do
      it{ should redirect_to new_user_registration_path }
    end

    context "when user logged in is different from backer" do
      let(:user){ create(:user) }
      it{ should redirect_to root_path }
      it('should set flash failure'){ request.flash[:alert].should_not be_empty }
    end

    context "when backer is logged in" do
      let(:user){ backer.user }
      it{ should be_successful }
      its(:body){ should =~ /#{I18n.t('projects.backers.show.title')}/ }
    end
  end

  describe "GET index" do
    before do
      create(:backer, value: 10.00, state: 'confirmed',
              reward: create(:reward, project: project, description: 'Test Reward'),
              project: project,
              user: create(:user, name: 'Foo Bar'))
      get :index, { locale: :pt, project_id: project.id }
    end
    its(:status){ should eq 200 }
  end
end
