require 'spec_helper'

describe BackersController do
  subject{ response }
  let(:project){ FactoryGirl.create(:project, state: 'successful') }
  let(:backer){ FactoryGirl.create(:backer, state: 'confirmed', project: project) }
  let(:current_user){ nil }
  let(:format){ 'json' }
  before do
    ::Configuration[:base_url] = 'http://catarse.me'
    controller.stub(:current_user).and_return(current_user)
    get :index, user_id: backer.user.id, locale: 'pt', format: format
  end

  describe "GET index" do
    context "when format is html" do
      let(:format){ 'html' }
      its(:status){ should == 404 }
    end

    context "when user can not manage the profile or is anonymous" do
      its(:status){ should == 200 }
      its(:body){ should == [backer].to_json({include_project: true, can_manage: false}) }
    end

    context "when user can manage the profile" do
      let(:current_user){ backer.user }
      its(:status){ should == 200 }
      its(:body){ should == [backer].to_json({include_project: true, can_manage: true}) }
    end
  end
  
  describe "POST request_refund" do
    let(:successful_project){ FactoryGirl.create(:project, state: 'successful') }
    let(:failed_project){ FactoryGirl.create(:project, state: 'failed') }
    let(:backer){ FactoryGirl.create(:backer, state: 'confirmed', user: user, project: failed_project) }
    let(:user){ FactoryGirl.create(:user, password: 'current_password', password_confirmation: 'current_password', authorizations: [FactoryGirl.create(:authorization, uid: 666, oauth_provider: FactoryGirl.create(:oauth_provider, name: 'facebook'))]) }

    before do
      BackerObserver.any_instance.stub(:notify_backoffice)
    end

    context "without user" do
      let(:current_user){ nil }
      before { post :request_refund, { user_id: user.id, id: backer.id } }

      it "should not set requested_refund" do
        backer.reload
        backer.requested_refund?.should be_false
      end
      it{ should redirect_to new_user_session_path }
    end
    
    context "when current_user have a confirmed backer" do
      let(:current_user) { user }      
      before { post :request_refund, { user_id: user.id, id: backer.id } }
      
      it do
        backer.reload
        backer.requested_refund?.should be_true 
      end
      
      it { should redirect_to user_path(current_user, anchor: 'credits') }
    end
    
    context "when current_user have a unconfirmed backer" do
      let(:current_user) { user }
      let(:unconfirmed_backer) { FactoryGirl.create(:backer, state: 'pending', user: user, project: failed_project) }
      before { post :request_refund, { user_id: user.id, id: unconfirmed_backer.id } }

      it do
        unconfirmed_backer.reload
        unconfirmed_backer.requested_refund?.should be_false 
      end

      it { should redirect_to user_path(current_user, anchor: 'credits') }      
    end
    
    context "when current_user is not owner of the backer" do
      let(:current_user) { FactoryGirl.create(:user) }
      let(:other_back) { FactoryGirl.create(:backer, project: failed_project) }
      let(:user) { other_back.user }
      before { post :request_refund, { user_id: user.id, id: other_back.id } }

      it do
        other_back.reload
        other_back.requested_refund?.should be_false 
      end

      it { should redirect_to root_path }
    end
  end  
end
