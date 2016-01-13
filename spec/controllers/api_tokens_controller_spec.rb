#encoding:utf-8
require 'rails_helper'

RSpec.describe ApiTokensController, type: :controller do
  let(:api_host){ "https://api.foo.com" }
  let(:jwt_secret){ 'gZH75aKtMN3Yj0iPS4hcgUuTwjAzZr9C' }
  let(:admin_token){ JsonWebToken.sign({role: 'admin', id: current_user.id.to_s}, key: jwt_secret) }
  let(:user_token){ JsonWebToken.sign({role: 'web_user', id: current_user.id.to_s}, key: jwt_secret) }
  subject{ response }

  before do
    CatarseSettings[:api_host] = api_host
    CatarseSettings[:jwt_secret] = jwt_secret
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "GET show" do
    let(:claims){ JsonWebToken.verify(JSON.parse(subject.body)["token"], key: jwt_secret) }

    before do
      get :show, locale: :pt
    end

    context "when we do not have api_host configured" do
      let(:api_host){ nil }

      let(:current_user) { create(:user) }
      it{ is_expected.to_not be_successful }
    end

    context "when I'm not logged in" do
      let(:current_user) { nil }
      it{ is_expected.to_not be_successful }
    end

    context "when I'm logged in as admin" do
      let(:current_user) { create(:user, admin: true) }
      it{ is_expected.to be_successful }
      it "should produce appropriate token" do
        expect(claims[:ok][:role]).to eq 'admin'
        expect(claims[:ok][:user_id]).to eq current_user.id.to_s
      end 
    end

    context "when I'm logged in as user" do
      let(:current_user) { create(:user, admin: false) }
      it{ is_expected.to be_successful }
      it "should produce appropriate token" do
        expect(claims[:ok][:role]).to eq 'web_user'
        expect(claims[:ok][:user_id]).to eq current_user.id.to_s
      end 
    end

  end

end
