#encoding:utf-8
require 'spec_helper'

describe UsersController do
  render_views
  subject{ response }
  before do
    controller.stub(:current_user).and_return(current_user)
  end

  let(:successful_project){ FactoryGirl.create(:project, state: 'successful') }
  let(:failed_project){ FactoryGirl.create(:project, state: 'failed') }
  let(:backer){ FactoryGirl.create(:backer, state: 'confirmed', user: user, project: failed_project) }
  let(:user){ FactoryGirl.create(:user, password: 'current_password', password_confirmation: 'current_password', authorizations: [FactoryGirl.create(:authorization, uid: 666, oauth_provider: FactoryGirl.create(:oauth_provider, name: 'facebook'))]) }
  let(:current_user){ user }

  describe "PUT update" do
    before do
      put :update, id: user.id, locale: 'pt', user: { twitter: 'test' }
    end
    it("should update the user") do
      user.reload
      user.twitter.should ==  'test'
    end
    it{ should redirect_to user_path(user, anchor: 'settings') }
  end

  describe "GET set_email" do
    before do
      get :set_email, locale: 'pt'
    end
    it{ should render_template('set_email') }
  end

  describe "PUT update_password" do
    let(:current_password){ 'current_password' }
    let(:password){ 'newpassword123' }
    let(:password_confirmation){ 'newpassword123' }
    before do
      put :update_password, id: user.id, locale: 'pt', user: { current_password: current_password, password: password, password_confirmation: password_confirmation }
    end

    context "with wrong current password" do
      let(:current_password){ 'wrong_password' }
      it{ flash[:error].should_not be_empty }
      it{ should redirect_to user_path(user, anchor: 'settings') }
    end

    context "with right current password and right confirmation" do
      it{ flash[:notice].should_not be_empty }
      it{ flash[:error].should be_nil }
      it{ should redirect_to user_path(user, anchor: 'settings') }
    end
  end

  describe "PUT update_email" do
    let(:email){ 'new_email@bar.com' }
    let(:return_to){ nil }
    before do
      session[:return_to] = return_to
      put :update_email, id: user.id, locale: 'pt', user: {email: email}
    end

    context "when email is not valid" do
      let(:email){ 'new_email_bar.com' }
      it{ should render_template('set_email') }
    end

    context "when email is valid and we have a session[:return_to]" do
      let(:return_to){ '/foo' }
      it{ should redirect_to return_to }
      it{ session[:return_to].should be_nil }
    end

    context "when email is valid" do
      it("should update the user") do
        user.reload
        user.email.should ==  'new_email@bar.com'
      end
      it{ should redirect_to user_path(user, anchor: 'settings') }
    end
  end

  describe "GET show" do
    before do
      FactoryGirl.create(:notification_type, name: 'updates')
      get :show, id: user.id, locale: 'pt'
    end

    it{ assigns(:fb_admins).should include(user.facebook_id.to_i) }
  end
end
