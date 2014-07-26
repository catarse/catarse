require 'spec_helper'

describe FeedbackForm do
  let(:form){ FeedbackForm.new email: 'diogo@biazus.me', message: 'test' }
  let(:delivery){ ActionMailer::Base.deliveries.last }
  describe "#deliver" do
    it "should deliver message" do
      form.deliver
      expect(delivery).to_not be_nil
    end
  end
end
