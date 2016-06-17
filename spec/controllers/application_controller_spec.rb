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
      cookies[:referral_link] = initial_session_value
      cookies[:origin_referral] = initial_origin_value
      controller.referral_it!
    end

    context "when we already have a referral link in session but referrer is external" do
      let(:referrer){ 'http://www.foo.bar' }
      let(:initial_session_value){ 'test' }
      let(:initial_origin_value) { nil }

      it "should clear and store ref in session" do
        expect(cookies[:referral_link]).to eq 'foo'
      end

      it "should store origin referral in session" do
        expect(cookies[:origin_referral]).to eq referrer
      end
    end

    context "when we already have a referral link in session" do
      let(:initial_session_value){ 'test' }
      let(:initial_origin_value) { 'origin' }

      it "should keep initial value on referral" do
        expect(cookies[:referral_link]).to eq initial_session_value
      end

      it "should keep initial value on origin" do
        expect(cookies[:origin_referral]).to eq initial_origin_value
      end
    end

    context "when we still do not have a referral link in session and the ref params is nil and referrer is external" do
      let(:referrer){ 'http://www.foo.bar' }
      let(:initial_session_value){ nil }
      let(:initial_origin_value) { nil }
      let(:params){ {ref: nil} }

      it "should keep referal link nil" do
        expect(cookies[:referral_link]).to eq nil
      end

      it "should store HTTP_REFERRER in origin" do
        expect(cookies[:origin_referral]).to eq referrer
      end
    end

    context "when we still have a referral link in session and the ref params is defined and referrer is nil" do
      let(:referrer){ nil }
      let(:initial_session_value){ 'test' }
      let(:initial_origin_value) { 'http://www.foo.bar' }
      let(:params){ {ref: nil} }

      it "should keep referal link as initial" do
        expect(cookies[:referral_link]).to eq initial_session_value
      end

      it "should keep HTTP_REFERRER as initial" do
        expect(cookies[:origin_referral]).to eq initial_origin_value
      end
    end

    context "when we still have a referral link in session and the ref params is nil and referrer is internal" do
      let(:referrer){ 'http://www.catarse.me' }
      let(:initial_session_value){ 'test' }
      let(:initial_origin_value) { 'http://www.foo.bar' }
      let(:params){ {ref: nil} }

      it "should keep referal link equals" do
        expect(cookies[:referral_link]).to eq 'test'
      end

      it "should store HTTP_REFERRER in origin" do
        expect(cookies[:origin_referral]).to eq 'http://www.foo.bar'
      end
    end

    context "when we still have a referral link in session and ref params and referrer is internal" do
      let(:referrer){ 'http://www.catarse.me' }
      let(:initial_session_value){ 'test' }
      let(:initial_origin_value) { 'http://www.foo.bar' }
      let(:params){ {ref: 'testado'} }

      it "should keep referal link equals" do
        expect(cookies[:referral_link]).to eq 'testado'
      end

      it "should store HTTP_REFERRER in origin" do
        expect(cookies[:origin_referral]).to eq 'http://www.foo.bar'
      end
    end

  end
end
