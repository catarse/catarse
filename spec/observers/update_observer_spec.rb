require 'spec_helper'

describe UpdateObserver do
  describe 'after_create' do
    context ".notify_backers" do
      before do
        Notification.unstub(:create_notification)
        Factory(:notification_type, :name => 'updates')
        @project = Factory(:project)
        backer = Factory(:backer, :confirmed => true, :project => @project)
        @project.reload
        ActionMailer::Base.deliveries = []
      end

      it "should send email to backers" do
        update = Update.create!(:user => @project.user, :project => @project, :comment => "this is a comment")
        ActionMailer::Base.deliveries.should_not be_empty
      end
    end
  end
end
