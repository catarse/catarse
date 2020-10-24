# encoding:utf-8
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiTokensController, type: :controller do
  let(:api_host) { 'https://api.foo.com' }
  let(:common_api_key) { 'someapikey' }
  let(:proxy_api_key) { 'platform_api_key_foobar' }
  let(:jwt_secret) { 'gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C' }
  let(:admin_token) { JWT.encode({ role: 'admin', id: current_user.id.to_s }, jwt_secret, 'HS256') }
  let(:user_token) { JWT.encode({ role: 'web_user', id: current_user.id.to_s }, jwt_secret, 'HS256') }
  subject { response }

  before do
    CatarseSettings[:api_host] = api_host
    CatarseSettings[:common_proxy_api_key] = proxy_api_key
    CatarseSettings[:common_api_key] = common_api_key
    CatarseSettings[:jwt_secret] = jwt_secret
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe 'GET common_proxy' do
    before do
      get :common_proxy, params: { locale: :pt }
    end

    context 'when we do not have common_proxy_api_host configured' do
      let(:proxy_api_key) { nil }

      let(:current_user) { create(:user) }
      it { is_expected.to_not be_successful }
    end

    context "when I'm not logged in" do
      let(:current_user) { nil }
      it { is_expected.to_not be_successful }
    end

    context "when I'm logged in as user" do
      let(:current_user) { create(:user, admin: false) }
      let(:common_wrapper_double) { double }
      before do
        allow(CommonWrapper).to receive(:new).and_return(common_wrapper_double)
        allow(common_wrapper_double).to receive(:temp_login_api_key).and_return('temp_login_api_key_mock')
        expect(common_wrapper_double).to receive(:temp_login_api_key)
        get :common_proxy, params: { locale: :pt }
      end
      it { is_expected.to be_successful }
      it do
        json = ActiveSupport::JSON.decode(response.body)
        expect(json['token']).to eq('temp_login_api_key_mock')
      end
      #it 'should produce appropriate token' do
      #  expect(claims['role']).to eq 'web_user'
      #  expect(claims['user_id']).to eq current_user.id.to_s
      #end
    end
  end

  describe 'GET show' do
    let(:claims) { JWT.decode(JSON.parse(subject.body)['token'], jwt_secret, true, { algorithm: 'HS256' })[0] }

    before do
      get :show, params: { locale: :pt }
    end

    context 'when we do not have api_host configured' do
      let(:api_host) { nil }

      let(:current_user) { create(:user) }
      it { is_expected.to_not be_successful }
    end

    context "when I'm not logged in" do
      let(:current_user) { nil }
      it { is_expected.to_not be_successful }
    end

    context "when I'm logged in as admin" do
      let(:current_user) { create(:user, admin: true) }
      it { is_expected.to be_successful }
      it 'should produce appropriate token' do
        expect(claims['role']).to eq 'admin'
        expect(claims['user_id']).to eq current_user.id.to_s
      end
    end

    context "when I'm logged in as user" do
      let(:current_user) { create(:user, admin: false) }
      it { is_expected.to be_successful }
      it 'should produce appropriate token' do
        expect(claims['role']).to eq 'web_user'
        expect(claims['user_id']).to eq current_user.id.to_s
      end
    end
  end
end
