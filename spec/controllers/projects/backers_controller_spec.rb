require 'spec_helper'

describe Projects::BackersController do
  render_views
  let(:failed_project) { Factory(:project, state: 'failed') }
  let(:project) { Factory(:project) }
  let(:backer){ Factory(:backer, value: 10.00, credits: true, confirmed: false, project: project) }
  let(:user){ nil }

  subject{ response }

  before do
    controller.stubs(:current_user).returns(user)
  end

  describe "PUT credits_checkout" do
    before do
      put :credits_checkout, { locale: :pt, project_id: project.id, id: backer.id }
    end

    context "without user" do
      it{ should redirect_to(login_path) }
    end

    context "when backer don't exist in current_user" do
      let(:user){ Factory(:user) }
      it{ should redirect_to(new_project_backer_path(project)) }
      it('should set flash failure'){ request.flash[:failure].should_not be_empty }
    end

    context "with correct user but insufficient credits" do
      let(:user){ backer.user }
      it('should not confirm backer'){ backer.reload.confirmed.should be_false }
      it('should set flash failure'){ request.flash[:failure].should == I18n.t('projects.backers.checkout.no_credits') }
      it{ should redirect_to(new_project_backer_path(project)) }
    end

    context "with correct user and sufficient credits" do
      let(:user) do 
        Factory(:backer, value: 10.00, credits: false, confirmed: true, user: backer.user, project: failed_project)
        backer.user
      end
      it('should confirm backer'){ backer.reload.confirmed.should be_true }
      it('should set flash success'){ request.flash[:success].should == I18n.t('projects.backers.checkout.success') }
      it{ should redirect_to(thank_you_project_backer_path(project_id: project.id, id: backer.id)) }
    end
  end

  describe "POST review" do
    before do
      request.env['REQUEST_URI'] = "/test_path"
      post :review, {locale: :pt, project_id: project.id, backer: { value: '20.00', reward_id: '0', anonymous: '0' }}
    end

    context "when no user is logged" do
      it{ should redirect_to login_path }
      it('should set the session[:return_to]'){ session[:return_to].should == "/test_path" }
    end

    context "when user is logged in" do
      let(:user){ Factory(:user) }
      its(:body){ should =~ /#{I18n.t('projects.backers.review.title')}/ }
      its(:body){ should =~ /#{project.name}/ }
      its(:body){ should =~ /R\$ 20/ }
    end
  end

  describe "GET new" do
    let(:secure_review_host){ nil }
    let(:user){ Factory(:user) }
    let(:can_back){ true }
    before do
      ::Configuration[:secure_review_host] = secure_review_host
      Project.any_instance.stubs(:can_back?).returns(can_back)
      get :new, {locale: :pt, project_id: project.id}
    end

    context "when no user is logged" do
      let(:user){ nil }
      it{ should redirect_to login_path }
    end

    context "when user is logged in but project.can_back? is false" do
      let(:can_back){ false }
      it{ should redirect_to root_path }
    end

    context "when project.can_back? is true and we have configured a secure review url" do
      let(:secure_review_host){ 'secure.catarse.me' }
      it "should assign the https url to @review_url" do
        assigns(:review_url).should == review_project_backers_url(project, host: Configuration[:secure_review_host], protocol: 'https')
      end
    end

    context "when project.can_back? is true and we have not configured a secure review url" do
      it{ should render_template("projects/backers/new") }
      it "should assign review_project_backers_path to @review_url" do
        assigns(:review_url).should == review_project_backers_path(project)
      end
      its(:body) { should =~ /#{I18n.t('projects.backers.new.header.title')}/ }
      its(:body) { should =~ /#{I18n.t('projects.backers.new.submit')}/ }
      its(:body) { should =~ /#{I18n.t('projects.backers.new.no_reward')}/ }
      its(:body) { should =~ /#{project.name}/ }
    end
  end

  describe "GET thank_you" do
    let(:backer){ Factory(:backer, value: 10.00, credits: false, confirmed: true) }
    before do
      get :thank_you, { locale: :pt, project_id: backer.project.id, id: backer.id }
    end

    context "when no user is logged in" do
      it{ should redirect_to root_path }
      it('should set flash failure'){ request.flash[:failure].should_not be_empty }
    end

    context "when user logged in is different from backer" do
      let(:user){ Factory(:user) }
      it{ should redirect_to root_path }
      it('should set flash failure'){ request.flash[:failure].should_not be_empty }
    end

    context "when backer is logged in" do
      let(:user){ backer.user }
      it{ should be_successful }
      its(:body){ should =~ /#{I18n.t('projects.backers.thank_you.title')}/ }
    end
  end

  describe "GET index" do
    before do
      Factory(:backer, value: 10.00, confirmed: true, 
              reward: Factory(:reward, project: project, description: 'Test Reward'), 
              project: project, 
              user: Factory(:user, name: 'Foo Bar'))
      get :index, { locale: :pt, project_id: project.id, format: :json }
    end

    shared_examples_for  "admin / owner" do
      it "should see all info from backer" do
        response_backer = ActiveSupport::JSON.decode(response.body)[0]
        response_backer['value'].should == 'R$ 10'
        response_backer['user']['name'].should == 'Foo Bar'
        response_backer['reward']['description'].should == 'Test Reward'
      end
    end

    shared_examples_for "normal / guest" do
      it "should see filtered info about backer" do
        response_backer = ActiveSupport::JSON.decode(response.body)[0]
        response_backer['value'].should == 'R$ 10'
        response_backer['user']['name'].should == 'Foo Bar'
        response_backer['reward'].should be_nil
      end
    end

    context "with admin user" do
      let(:user){ Factory(:user, admin: true)}
      it_should_behave_like "admin / owner"
    end

    context "with project owner user" do
      let(:user){ Factory(:user, admin: false)}
      let(:project) { Factory(:project, user: user) }
      it_should_behave_like "admin / owner"
    end

    context "with normal user" do
      it_should_behave_like "normal / guest"
    end

    context "guest user" do
      let(:user){ nil }
      it_should_behave_like "normal / guest"
    end
  end
end
