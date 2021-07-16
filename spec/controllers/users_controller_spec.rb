# encoding:utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'redirect to edit_user_path' do
  let(:action) { nil }
  let(:anchor) { nil }

  context 'when user is logged' do
    let(:current_user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      get action, params: { id: current_user.id, locale: :pt }
    end

    it { is_expected.to redirect_to edit_user_path(current_user, anchor: (anchor || action.to_s)) }
  end

  context 'when user is not logged' do
    let(:current_user) { create(:user) }

    before do
      allow(controller).to receive(:current_user).and_return(nil)
      get :settings, params: { id: current_user.id, locale: :pt }
    end

    it { is_expected.to redirect_to sign_up_path }
  end
end

RSpec.describe UsersController, type: :controller do
  render_views
  subject { response }
  before do
    allow(controller).to receive(:current_user).and_return(current_user)
    allow_any_instance_of(User).to receive(:cancel_all_subscriptions).and_return(true)
  end

  let(:successful_project) { create(:project, state: 'successful') }
  let(:failed_project) { create(:project, state: 'failed') }
  let(:user) { create(:user, password: 'current_password', password_confirmation: 'current_password', authorizations: [create(:authorization, uid: 666, oauth_provider: create(:oauth_provider, name: 'facebook'))]) }
  let(:current_user) { user }

  describe 'GET settings' do
    it_should_behave_like 'redirect to edit_user_path' do
      let(:action) { :settings }
    end
  end

  describe 'GET billing' do
    it_should_behave_like 'redirect to edit_user_path' do
      let(:action) { :settings }
    end
  end

  describe 'GET reactivate' do
    let(:current_user) { nil }

    before do
      user.deactivate
    end

    context 'when token is nil' do
      let(:token) { 'nil' }

      before do
        expect(controller).to_not receive(:sign_in)
        get :reactivate, params: { id: user.id, token: token, locale: :pt }
      end

      it 'should not set deactivated_at to nil' do
        expect(user.reload.deactivated_at).to_not be_nil
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when token is NOT valid' do
      let(:token) { 'invalid token' }

      before do
        expect(controller).to_not receive(:sign_in)
        get :reactivate, params: { id: user.id, token: token, locale: :pt }
      end

      it 'should not set deactivated_at to nil' do
        expect(user.reload.deactivated_at).to_not be_nil
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when token is valid' do
      let(:token) { user.reactivate_token }

      before do
        expect(controller).to receive(:sign_in).with(user)
        get :reactivate, params: { id: user.id, token: token, locale: :pt }
      end

      it 'should set deactivated_at to nil' do
        expect(user.reload.deactivated_at).to be_nil
      end

      it { is_expected.to redirect_to root_path }
    end
  end

  describe 'DELETE destroy' do
    context 'when user has published_projects' do
      let(:project) { create(:project, state: 'online', user: user) }
      before do
        allow(controller).to receive(:current_user).and_call_original
        delete :destroy, params: { id: user.id, locale: :pt }
      end

      it 'should not set deactivated_at' do
        expect(user.reload.deactivated_at).to be_nil
      end

      it { is_expected.not_to redirect_to user_path(user, anchor: 'settings') }
    end
    context 'when user is beign deactivated by admin' do
      before do
        allow(controller).to receive(:current_user).and_call_original
        sign_in(create(:user, admin: true))
        delete :destroy, params: { id: user.id, locale: :pt }
      end

      it 'should set deactivated_at' do
        expect(user.reload.deactivated_at).to_not be_nil
      end

      it 'should not sign user out' do
        expect(controller.current_user).to_not be_nil
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when user is loged' do
      before do
        allow(controller).to receive(:current_user).and_call_original
        sign_in(current_user)
        delete :destroy, params: { id: user.id, locale: :pt }
      end

      it 'should set deactivated_at' do
        expect(user.reload.deactivated_at).to_not be_nil
      end

      it 'should sign user out' do
        expect(controller.current_user).to be_nil
      end

      it { is_expected.to redirect_to root_path }
    end

    context 'when user is not loged' do
      let(:current_user) { nil }
      before do
        delete :destroy, params: { id: user.id, locale: :pt }
      end

      it 'should not set deactivated_at' do
        expect(user.reload.deactivated_at).to be_nil
      end

      it { is_expected.not_to redirect_to user_path(user, anchor: 'settings') }
    end
  end

  describe 'GET unsubscribe_notifications' do
    context 'when user is loged' do
      before do
        get :unsubscribe_notifications, params: { id: user.id, locale: 'pt' }
      end

      it { is_expected.to redirect_to edit_user_path(user, anchor: 'notifications') }
    end

    context 'when user is not loged' do
      let(:current_user) { nil }
      before do
        get :unsubscribe_notifications, params: { id: user.id, locale: 'pt' }
      end

      it { is_expected.to redirect_to new_user_registration_path }
    end
  end

  describe 'POST new_password' do
    context 'without password parameter' do
      before do
        post :new_password, params: { id: user.id, locale: 'pt' }
      end

      it { expect(response.status).to eq 400 }
      it { expect(response.content_type).to include 'application/json' }
      it { expect(JSON.parse(response.body)).to eq JSON.parse('{"errors": ["Missing parameter password"]}') }
    end

    context 'with an invalid password parameter' do
      before do
        post :new_password, params: { id: user.id, locale: 'pt', password: '12' }
      end

      it { expect(response.status).to eq 400 }
      it { expect(response.content_type).to include 'application/json' }
      it { expect(JSON.parse(response.body)).to eq JSON.parse('{"errors":["Senha A senha é muito curta. Mínimo 6 caracteres."]}') }
    end

    context 'with a valid password parameter' do
      before do
        post :new_password, params: { id: user.id, locale: 'pt', password: 'newpassword123' }
      end

      it { expect(response.status).to eq 200 }
      it { expect(response.content_type).to include 'application/json' }
      it { expect(JSON.parse(response.body)).to eq JSON.parse('{"success": "OK"}') }
    end
  end

  describe 'update user links' do

    def stub_link_params(links)
      params = {
        id: current_user.id,
        user: { links_attributes: links }
      }
    end

    context 'save user links' do
      it 'should create one link' do
        # given
        params = stub_link_params([{ link: 'http://link' }])

        # when
        patch :update, params: params
        current_user.reload

        # then
        expect(current_user.links.length).to eq(1)
        expect(current_user.links[0].link).to eq('http://link')
      end

      it 'should create two links' do
        # given
        params = stub_link_params [
          { link: 'http://link1' },
          { link: 'http://link2' }
        ]

        # when
        patch :update, params: params
        current_user.reload

        # then
        expect(current_user.links.length).to eq(2)
        expect(current_user.links[0].link).to eq('http://link1')
        expect(current_user.links[1].link).to eq('http://link2')
      end

      it 'should update one link' do
        # given
        params = stub_link_params [{ link: 'http://link1' }]
        patch :update, params: params

        # when
        params = stub_link_params [
          { id: current_user.links[0].id, link: 'http://new_link1' },
        ]
        patch :update, params: params
        current_user.reload

        # then
        expect(current_user.links[0].link).to eq('http://new_link1')
      end

      it 'should make no updates to the links' do
        # given
        params = stub_link_params []
        params[:user][:name] = 'new name'

        # when
        patch :update, params: params
        current_user.reload

        # then
        expect(current_user.links.length).to eq(0)
      end

      it 'should make no updates to the links when it is null' do
        # given
        params = {
          id: current_user.id,
          user: {
            name: 'new user name',
            links_attributes: nil
          }
        }

        # when
        patch :update, params: params
        current_user.reload

        # then
        expect(current_user.links.length).to eq(0)
      end

      it 'should allow updates to user data' do
        # given
        params = {
          id: current_user.id,
          user: {
            name: 'new user name'
          }
        }

        # when
        patch :update, params: params
        current_user.reload

        # then
        expect(current_user.links.length).to eq(0)
      end
    end

    context 'destroy user link' do
      it 'should destroy link' do
        # given
        params = stub_link_params [{ link: 'http://link1' }]
        patch :update, params: params

        # when
        params = stub_link_params [
          { id: current_user.links[0].id, link: 'http://new_link1', _destroy: true },
        ]
        patch :update, params: params
        current_user.reload

        # then
        expect(current_user.links.length).to eq(0)
      end
    end
  end
end
