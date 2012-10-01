require 'spec_helper'

describe Notification do
  it{ should belong_to :user }
  it{ should belong_to :project }

  let(:notification_type){ Factory(:notification_type, :name => 'confirm_backer') }

  describe "#send_email" do
    context "when dismissed is true" do
      let(:notification){ Factory(:notification, :dismissed => true) }
      before{ notification.send_email }
      it("should not send email"){ ActionMailer::Base.deliveries.should be_empty }
    end

    context "when dismissed is false" do
      let(:notification){ Factory(:notification, :dismissed => false) }
      before{ notification.send_email }
      it("should send email"){ ActionMailer::Base.deliveries.should_not be_empty }
      it("should dismiss the notification"){ notification.dismissed.should be_true }
    end
  end
end
