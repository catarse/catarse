require 'spec_helper'

describe Notification do
  it{ should belong_to :user }
  it{ should belong_to :project }
  it{ should belong_to :notification_type }
  it{ should belong_to :backer }

  let(:backer){ Factory(:backer) }
  let(:notification_type){ Factory(:notification_type, :name => 'confirm_backer') }

  before do
    Notification.unstub(:create_notification)
    Notification.unstub(:create_notification_once)
    ActionMailer::Base.deliveries.clear 
  end

  describe "#send_email" do
    context "when dismissed is true" do
      let(:notification){ Factory(:notification, :dismissed => true, :notification_type => notification_type) }
      before{ notification.send_email }
      it("should not send email"){ ActionMailer::Base.deliveries.should be_empty }
    end

    context "when dismissed is false" do
      let(:notification){ Factory(:notification, :dismissed => false, :notification_type => notification_type) }
      before{ notification.send_email }
      it("should send email"){ ActionMailer::Base.deliveries.should_not be_empty }
      it("should dismiss the notification"){ notification.dismissed.should be_true }
    end
  end

  describe ".notify_backer" do
    before do
      notification_type
      backer =  Factory(:backer)
      user = mock
      user.stubs(:name).returns('foo')
      backer.stubs(:user).returns(user)
    end

    context "when NotificationType with the provided name does not exist" do
      subject{ Notification.create_notification(:test, backer.user) }
      it("should raise error"){ lambda{ subject }.should raise_error("There is no NotificationType with name test") }
    end

    context "when NotificationType with the provided name exists" do
      subject{ Notification.create_notification(:confirm_backer, backer.user, :backer => backer,  :project_name => backer.project.name) }
      its(:dismissed){ should be_true }
      its(:backer){ should == backer }
    end
  end
end
