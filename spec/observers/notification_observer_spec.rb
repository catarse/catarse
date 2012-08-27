require 'spec_helper'

describe NotificationObserver do
  describe "after_create" do
    it 'When email, subject and text are filled should delivery an email to user' do
      ActionMailer::Base.deliveries.should be_empty
      Factory.create(:notification)
      ActionMailer::Base.deliveries.should_not be_empty
    end
  end
end
