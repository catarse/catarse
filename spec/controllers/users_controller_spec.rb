#encoding:utf-8
require 'rails_helper'

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

      it { is_expected.to redirect_to user_path(user, anchor: 'unsubscribes')  }
    end

    context "when user is not loged" do
      let(:current_user) { nil }
      before do
        get :unsubscribe_notifications, id: user.id, locale: 'pt'
      end

      it { is_expected.not_to redirect_to user_path(user, anchor: 'unsubscribes')  }
    end
  end

  describe "PUT update" do
    before do
      put :update, id: user.id, locale: 'pt', user: { twitter: 'test' }
    end
    it("should update the user") do
      user.reload
      expect(user.twitter).to eq('test')
    end
    it{ is_expected.to redirect_to user_path(user, anchor: 'settings') }
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
      it{ expect(flash[:error]).not_to be_empty }
      it{ is_expected.to redirect_to user_path(user, anchor: 'settings') }
    end

    context "with right current password and right confirmation" do
      it{ expect(flash[:notice]).not_to be_empty }
      it{ expect(flash[:error]).to be_nil }
      it{ is_expected.to redirect_to user_path(user, anchor: 'settings') }
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
