require 'spec_helper'

describe FeedbacksController do
  subject{ response }

  let(:delivery){ ActionMailer::Base.deliveries.last }

  describe "GET create" do
    before do
      post :create, feedback: {email: 'foo@bar.com', message: 'test'}
    end
    it{ should be_success }

    it "should deliver feedback" do
      expect(delivery).to_not be_nil
      expect(delivery.to).to eq ['foo@bar.com']
      expect(delivery.body.raw_source).to include 'test'
    end
  end
end
