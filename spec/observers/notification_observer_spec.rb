require 'spec_helper'

describe NotificationObserver do
  describe "after_create" do
    before do
      ActionMailer::Base.deliveries = []
    end
    it 'When email, subject and text are filled should delivery an email to user' do
      FactoryGirl.create(:notification)
      ActionMailer::Base.deliveries.should_not be_empty
    end
  end
end
