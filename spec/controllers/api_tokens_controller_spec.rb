#encoding:utf-8
require 'rails_helper'

RSpec.describe ApiTokensController, type: :controller do
  let(:api_host){ "https://api.foo.com" }
  let(:http_spy){ class_spy("Typhoeus") }
  let(:response_spy){ spy("response") }
  subject{ response }

  before do
    allow(controller).to receive(:http_requester).and_return(http_spy)
    allow(http_spy).to receive(:post).and_return(response_spy)
    allow(response_spy).to receive(:body).and_return({token: 'test'}.to_json)
    CatarseSettings[:api_host] = api_host
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  describe "GET show" do

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

    context "when I'm logged in" do
      let(:current_user) { create(:user) }
      it{ is_expected.to be_successful }
      it "should relay request to api server" do
        expect(http_spy).to have_received(:post).with("#{CatarseSettings[:api_host]}/postgrest/tokens", body: {
          id: current_user.id.to_s,
          pass: current_user.authentication_token}.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Accept' => 'application/json'
          })
      end
    end

  end

end
