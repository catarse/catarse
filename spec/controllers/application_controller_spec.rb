#encoding:utf-8
require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:params){ {ref: 'foo'} }

  before do
    request.env['HTTP_REFERER'] = 'http_referrer'
    allow(controller).to receive(:params).and_return(params)
  end

  describe "#referral_it!" do
    before do
      session[:referral_link] = initial_session_value
      controller.referral_it!
    end

    context "when we already have a referral link in session" do
      let(:initial_session_value){ 'test' }
      it "should store ref in session" do
        expect(session[:referral_link]).to eq initial_session_value
      end
    end

    context "when we still do not have a referral link in session and the ref params is nil" do
      let(:initial_session_value){ nil }
      let(:params){ {ref: nil} }
      it "should store ref in session" do
        expect(session[:referral_link]).to eq request.env['HTTP_REFERER']
      end
    end

    context "when we still do not have a referral link in session" do
      let(:initial_session_value){ nil }
      it "should store ref in session" do
        expect(session[:referral_link]).to eq params[:ref]
      end
    end
  end
end

