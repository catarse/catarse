# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OmniauthCallbacksController, type: :controller do
  before do
    facebook_provider
    OmniauthCallbacksController.add_providers
    @request.env['devise.mapping'] = Devise.mappings[:user]
    stub_request(:get, 'https://graph.facebook.com/v9.0/547955110/picture?type=large').to_return(status: 200)
  end

  let(:return_to) { nil }
  let(:user) { create(:user, authorizations: [create(:authorization, uid: oauth_data[:uid], oauth_provider: facebook_provider)]) }
  let(:facebook_provider) { create :oauth_provider, name: 'facebook' }
  let(:oauth_data) do
    Hashie::Mash.new({
      credentials: {
        expires: true,
        expires_at: 1_366_644_101,
        token: 'AAAHuZCwF61OkBAOmLTwrhv52pZCriPnTGIasdasdasdascNhZCZApsZCSg6POZCQqolxYjnqLSVH67TaRDONx72fXXXB7N7ZBByLZCV7ldvagm'
      },
      extra: {
        raw_info: {
          bio: 'I, simply am not there',
          email: 'diogob@gmail.com',
          first_name: 'Diogo',
          gender: 'male',
          id: '547955110',
          last_name: 'Biazus',
          link: 'http://www.facebook.com/diogo.biazus',
          locale: 'pt_BR',
          name: 'Diogo, Biazus',
          timezone: -3,
          updated_time: '2012-08-01T18:22:50+0000',
          username: 'diogo.biazus',
          verified: true
        }
      },
      info: {
        description: 'I, simply am not there',
        email: 'diogob@gmail.com',
        first_name: 'Diogo',
        image: 'http://graph.facebook.com/547955110/picture?type:, square',
        last_name: 'Biazus',
        name: 'Diogo, Biazus',
        urls: {
          Facebook: 'http://www.facebook.com/diogo.biazus'
        },
        verified: true
      },
      provider: 'facebook',
      uid: '547955110'
    })
  end

  subject { response }

  describe '.add_providers' do
    subject { controller }
    it { is_expected.to respond_to(:facebook) }
  end

  describe 'GET facebook' do
    describe 'when user already loged in' do
      let(:user) { create(:user, name: 'Foo') }

      before do
        allow(controller).to receive(:current_user).and_return(user)
        session[:return_to] = return_to
        request.env['omniauth.auth'] = oauth_data
        get :facebook
      end

      describe 'assigned user' do
        subject { assigns(:auth).user }
        it { expect(subject.name).to eq 'Foo' }
        it { expect(subject.authorizations.count).to eq 1 }
      end

      it { is_expected.to redirect_to root_path }
    end

    describe 'when user not loged in' do
      before do
        user
        session[:return_to] = return_to
        request.env['omniauth.auth'] = oauth_data
        get :facebook
      end

      context 'when there is no such user but we retrieve the email from omniauth' do
        let(:user) { nil }
        describe 'assigned user' do
          subject { assigns(:auth).user }
          it { expect(subject.email).to eq 'diogob@gmail.com' }
          it { expect(subject.name).to eq 'Diogo, Biazus' }
        end
        it { is_expected.to redirect_to root_path }
      end

      context 'when there is a valid user with this provider and uid and session return_to is /foo' do
        let(:return_to) { '/foo' }
        it { expect(assigns(:auth).user).to eq(user) }
        it { is_expected.to redirect_to '/foo' }
      end

      context 'when there is a valid user with this provider and uid and session return_to is nil' do
        it { expect(assigns(:auth).user).to eq(user) }
        it { is_expected.to redirect_to root_path }
      end
    end
  end
end
