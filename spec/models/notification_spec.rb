require 'spec_helper'

describe Notification do
  it{ should belong_to :user }
  it{ should belong_to :project }
  it{ should belong_to :notification_type }
  it{ should belong_to :backer }

  let(:backer){ Factory(:backer) }
  let(:notification_type){ Factory(:notification_type, :name => 'confirm_backer') }

  before{ ActionMailer::Base.deliveries.clear }

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
    end

    context "when NotificationType with the provided name does not exist" do
      subject{ Notification.notify_backer(backer, :test) }
      it("should raise error"){ lambda{ subject }.should raise_error("There is no NotificationType with name test") }
    end

    context "when NotificationType with the provided name exists" do
      subject{ Notification.notify_backer(backer, :confirm_backer) }
      its(:dismissed){ should be_true }
      its(:backer){ should == backer }
    end
  end
end
