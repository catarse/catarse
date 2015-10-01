#encoding:utf-8
require 'rails_helper'

RSpec.shared_examples "redirect to edit_user_path" do
  let(:action) { nil }
  let(:anchor) { nil }

  context "when user is logged" do
    let(:current_user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      get action, id: current_user.id, locale: :pt
    end

    it { is_expected.to redirect_to edit_user_path(current_user, anchor: (anchor || action.to_s)) }
  end

  context "when user is not logged" do
    let(:current_user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(nil)
      get :settings, id: current_user.id, locale: :pt
    end

    it { is_expected.to redirect_to sign_up_path }
  end

end

RSpec.describe UsersController, type: :controller do
  render_views
  subject{ response }
  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  let(:successful_project){ create(:project, state: 'successful') }
  let(:failed_project){ create(:project, state: 'failed') }
  let(:contribution){ create(:contribution, state: 'confirmed', user: user, project: failed_project) }
  let(:user){ create(:user, password: 'current_password', password_confirmation: 'current_password', authorizations: [create(:authorization, uid: 666, oauth_provider: create(:oauth_provider, name: 'facebook'))]) }
  let(:current_user){ user }

  describe "GET settings" do
    it_should_behave_like "redirect to edit_user_path" do
      let(:action) { :settings }
    end
  end

  describe "GET billing" do
    it_should_behave_like "redirect to edit_user_path" do
      let(:action) { :billing }
    end
  end

  describe "GET reactivate" do
    let(:current_user) { nil }

    before do
      user.deactivate
    end

    context "when token is nil" do
      let(:token){ 'nil' }

      before do
        expect(controller).to_not receive(:sign_in)
        get :reactivate, id: user.id, token: token, locale: :pt
      end

      it "should not set deactivated_at to nil" do
        expect(user.reload.deactivated_at).to_not be_nil
      end

      it { is_expected.to redirect_to root_path  }
    end

    context "when token is NOT valid" do
      let(:token){ 'invalid token' }

      before do
        expect(controller).to_not receive(:sign_in)
        get :reactivate, id: user.id, token: token, locale: :pt
      end

      it "should not set deactivated_at to nil" do
        expect(user.reload.deactivated_at).to_not be_nil
      end

      it { is_expected.to redirect_to root_path  }
    end

    context "when token is valid" do
      let(:token){ user.reactivate_token }

      before do
        expect(controller).to receive(:sign_in).with(user)
        get :reactivate, id: user.id, token: token, locale: :pt
      end

      it "should set deactivated_at to nil" do
        expect(user.reload.deactivated_at).to be_nil
      end

      it { is_expected.to redirect_to root_path  }
    end
  end

  describe "DELETE destroy" do
    context "when user is beign deactivated by admin" do
      before do
        allow(controller).to receive(:current_user).and_call_original
        sign_in(create(:user, admin: true))
        delete :destroy, id: user.id, locale: :pt
      end

      it "should set deactivated_at" do
        expect(user.reload.deactivated_at).to_not be_nil
      end

      it "should not sign user out" do
        expect(controller.current_user).to_not be_nil
      end

      it { is_expected.to redirect_to root_path  }
    end

    context "when user is loged" do
      before do
        allow(controller).to receive(:current_user).and_call_original
        sign_in(current_user)
        delete :destroy, id: user.id, locale: :pt
      end

      it "should set deactivated_at" do
        expect(user.reload.deactivated_at).to_not be_nil
      end

      it "should sign user out" do
        expect(controller.current_user).to be_nil
      end

      it { is_expected.to redirect_to root_path  }
    end

    context "when user is not loged" do
      let(:current_user) { nil }
      before do
        delete :destroy, id: user.id, locale: :pt
      end

      it "should not set deactivated_at" do
        expect(user.reload.deactivated_at).to be_nil
      end

      it { is_expected.not_to redirect_to user_path(user, anchor: 'settings')  }
    end
  end

  describe "GET unsubscribe_notifications" do
    context "when user is loged" do
      before do
        get :unsubscribe_notifications, id: user.id, locale: 'pt'
      end

      it { is_expected.to redirect_to edit_user_path(user, anchor: 'notifications')  }
    end

    context "when user is not loged" do
      let(:current_user) { nil }
      before do
        get :unsubscribe_notifications, id: user.id, locale: 'pt'
      end

      it { is_expected.to redirect_to new_user_registration_path  }
    end
  end

  describe "PUT update" do
    context "with password parameters" do
      let(:current_password){ 'current_password' }
      let(:password){ 'newpassword123' }
      let(:password_confirmation){ 'newpassword123' }

      before do
        put :update, id: user.id, locale: 'pt', user: { current_password: current_password, password: password, password_confirmation: password_confirmation }
      end

      context "with wrong current password" do
        let(:current_password){ 'wrong_password' }
        it{ expect(user.errors).not_to be_nil }
        it{ is_expected.not_to redirect_to edit_user_path(user) }
      end

      context "with right current password and right confirmation" do
        it{ expect(flash[:notice]).not_to be_empty }
        it{ is_expected.to redirect_to edit_user_path(user) }
      end
    end

    context "with out password parameters" do
      let(:project){ create(:project, state: 'successful') }
      let(:category){ create(:category) }
      before do
        put :update, id: user.id, locale: 'pt', user: { twitter: 'test', unsubscribes: {project.id.to_s=>"1"}, category_followers_attributes: [{category_id: category.id}]}
      end
      it("should update the user and nested models") do
        user.reload
        expect(user.twitter).to eq('test')
        expect(user.category_followers.size).to eq(1)
      end
      it{ is_expected.to redirect_to edit_user_path(user) }
    end

    context "removing category followers" do
      let(:project){ create(:project, state: 'successful') }
      before do
        create(:category_follower, user: user)
        put :update, id: user.id, locale: 'pt', user: { twitter: 'test', unsubscribes: {project.id.to_s=>"1"}, category_followers_attributes: []}
      end
      it("should clear category followers") do
        user.reload
        expect(user.category_followers.size).to eq(0)
      end
      it{ is_expected.to redirect_to edit_user_path(user) }
    end
  end

  describe "GET show" do
    before do
      get :show, id: user.id, locale: 'pt'
    end

    context "when user is no longer active" do
      let(:user){ create(:user, deactivated_at: Time.now) }
      its(:status){ should eq 404 }
    end

    context "when user is active" do
      it{ is_expected.to be_successful }
      it{ expect(assigns(:fb_admins)).to include(user.facebook_id.to_i) }
    end
  end
end
