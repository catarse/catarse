require 'spec_helper'

describe Users::BackersController do
  subject{ response }
  let(:user){ create(:user, password: 'current_password', password_confirmation: 'current_password', authorizations: [create(:authorization, uid: 666, oauth_provider: create(:oauth_provider, name: 'facebook'))]) }
  let(:successful_project){ create(:project, state: 'online') }
  let(:failed_project){ create(:project, state: 'online') }
  let(:successful_backer){ create(:backer, state: 'confirmed', project: successful_project) }
  let(:failed_backer){ create(:backer, state: 'confirmed', user: user, project: failed_project) }
  let(:other_back) { create(:backer, project: failed_project) }
  let(:unconfirmed_backer) { create(:backer, state: 'pending', user: user, project: failed_project) }
  let(:current_user){ nil }
  let(:format){ 'json' }
  before do
    ::Configuration[:base_url] = 'http://catarse.me'
    controller.stub(:current_user).and_return(current_user)
    successful_backer
    failed_backer
    unconfirmed_backer
    other_back
    successful_project.update_attributes state: 'successful'
    failed_project.update_attributes state: 'failed'
  end

  describe "GET index" do
    before do
      get :index, user_id: successful_backer.user.id, locale: 'pt'
    end

    its(:status){ should == 200 }
  end
  
  describe "POST request_refund" do
    before do
      BackerObserver.any_instance.stub(:notify_backoffice)
    end

    context "without user" do
      let(:current_user){ nil }
      before { post :request_refund, { user_id: user.id, id: failed_backer.id } }

      it "should not set requested_refund" do
        failed_backer.reload
        failed_backer.requested_refund?.should be_false
      end
      it{ should redirect_to new_user_registration_path }
    end
    
    context "when current_user have a confirmed backer" do
      let(:current_user) { user }      
      before { post :request_refund, { user_id: user.id, id: failed_backer.id } }
      
      it do
        failed_backer.reload
        failed_backer.requested_refund?.should be_true 
      end
      
      it { should redirect_to user_path(current_user, anchor: 'credits') }
    end
    
    context "when current_user have a unconfirmed backer" do
      let(:current_user) { user }
      before { post :request_refund, { user_id: user.id, id: unconfirmed_backer.id } }

      it do
        unconfirmed_backer.reload
        unconfirmed_backer.requested_refund?.should be_false 
      end

      it { should redirect_to user_path(current_user, anchor: 'credits') }      
    end
    
    context "when current_user is not owner of the backer" do
      let(:current_user) { create(:user) }
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
