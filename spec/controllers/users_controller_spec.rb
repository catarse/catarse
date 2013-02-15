#encoding:utf-8
require 'spec_helper'

describe UsersController do
  render_views
  subject{ response }
  before do
    controller.stubs(:current_user).returns(current_user)
  end

  let(:successful_project){ FactoryGirl.create(:project, state: 'successful') }
  let(:failed_project){ FactoryGirl.create(:project, state: 'failed') }
  let(:backer){ FactoryGirl.create(:backer, :user => user, :project => failed_project) }
  let(:user){ FactoryGirl.create(:user, :provider => 'facebook', :uid => '666') }
  let(:current_user){ user }

  describe "PUT update" do
    before do
      put :update, id: user.id, locale: 'pt', user: { twitter: 'test' }
    end
    it {
      user.reload
      user.twitter.should ==  'test'
    }
  end

  describe "GET show" do
    before do
      FactoryGirl.create(:notification_type, name: 'updates')
      get :show, :id => user.id, :locale => 'pt'
    end

    it{ assigns(:fb_admins).should include(user.facebook_id.to_i) }
  end

  describe "POST request_refund" do
    let(:previous_backs){ nil }
    let(:response_body){ {status: status_message, credits: user.reload.display_credits}.to_json }
    let(:status_message){ nil }

    before do
      previous_backs
      post :request_refund, { id: user.id, back_id: backer.id }
    end

    context "without user" do
      let(:current_user){ nil }
      it "should not set requested_refund" do
        backer.reload
        backer.requested_refund.should be_false
      end
      it{ should redirect_to new_user_session_path }
    end

    context "with user when we have the value to refund" do
      let(:status_message){ I18n.t('credits.index.refunded') }
      its(:body){ should == response_body }
    end

    context "with user when we do not have the value to refund" do
      let(:status_message){ I18n.t('credits.refund.no_credits') }
      let(:previous_backs){ FactoryGirl.create(:backer, :user => user, :project => successful_project, :credits => true) }
      its(:body){ should == response_body }
    end

    context "when backer cannot be refunded" do
      let(:status_message){ I18n.t('credits.refund.refunded') }
      let(:backer){ FactoryGirl.create(:backer, :user => user, :project => failed_project, :refunded => true) }
      its(:body){ should == response_body }
    end

    context "when backer already requested to refund" do
      let(:status_message){ I18n.t('credits.refund.requested_refund') }
      let(:backer){ FactoryGirl.create(:backer, :user => user, :project => failed_project, :requested_refund => true) }
      its(:body){ should == response_body }
    end
  end
end
