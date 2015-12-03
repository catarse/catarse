#encoding:utf-8
require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:params){ {ref: 'foo'} }
  let(:referrer){ 'http://www.catarse.me' }

  before do
    request.env['HTTP_REFERER'] = referrer
    allow(controller).to receive(:params).and_return(params)
  end

  describe "#referral_it!" do
    before do
      session[:referral_link] = initial_session_value
      session[:origin_referral] = initial_origin_value
      controller.referral_it!
    end

    context "when we already have a referral link in session but referrer is external" do
      let(:referrer){ 'http://www.foo.bar' }
      let(:initial_session_value){ 'test' }
      let(:initial_origin_value) { nil }

      it "should clear and store ref in session" do
        expect(session[:referral_link]).to eq 'foo'
      end

      it "should store origin referral in session" do
        expect(session[:origin_referral]).to eq referrer
      end
    end

    context "when we already have a referral link in session" do
      let(:initial_session_value){ 'test' }
      let(:initial_origin_value) { 'origin' }

      it "should keep initial value on referral" do
        expect(session[:referral_link]).to eq initial_session_value
      end

      it "should keep initial value on origin" do
        expect(session[:origin_referral]).to eq initial_origin_value
      end
    end

    context "when we still do not have a referral link in session and the ref params is nil and referrer is external" do
      let(:referrer){ 'http://www.foo.bar' }
      let(:initial_session_value){ nil }
      let(:initial_origin_value) { nil }
      let(:params){ {ref: nil} }

      it "should keep referal link nil" do
        expect(session[:referral_link]).to eq nil
      end

      it "should store HTTP_REFERRER in origin" do
        expect(session[:origin_referral]).to eq referrer
      end
    end
  end
end

