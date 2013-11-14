require 'spec_helper'

describe Notification do
  let(:backer){ create(:backer) }

  before do
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
    ActionMailer::Base.deliveries.clear
  end

  describe "Associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
    it{ should belong_to :backer }
    it{ should belong_to :project_update }
  end

  describe "#deliver" do
    let(:deliver_exception){ nil }
    let(:notification){ create(:notification, dismissed: false) }

    before do
      deliver_exception
      notification.deliver
    end

    context "when dismissed is true" do
      let(:notification){ create(:notification, dismissed: true) }
      it("should not send email"){ ActionMailer::Base.deliveries.should be_empty }
    end

    context "when dismissed is false" do
      it("should send email"){ ActionMailer::Base.deliveries.should_not be_empty }
      it("should dismiss the notification"){ notification.dismissed.should be_true }
    end
  end

  describe ".notify" do
    let(:notification){ build(:notification) }
    let(:notify){ Notification.notify(notification.template_name, notification.user) }
    before do
      Notification.should_receive(:create!).with({
        template_name: notification.template_name, 
        user: notification.user,
        locale: notification.user.locale,
        origin_email: Configuration['email_contact'],
        origin_name: Configuration[:company_name]
      }).and_return(notification)
      notification.should_receive(:deliver)
    end
    it("should create and send email"){ notify }
  end

  describe ".notify_once" do
    let(:notification){ create(:notification) }
    let(:notify_once){ Notification.notify_once(notification.template_name, notification.user, filter) }

    context "when filter is nil" do
      let(:filter){ nil }
      before do
        Notification.should_receive(:notify).with(notification.template_name, notification.user, {})
      end
      it("should call notify"){ notify_once }
    end

    context "when filter returns a previous notification" do
      let(:filter){ { user_id: notification.user.id } }
      before do
        Notification.should_not_receive(:notify)
      end
      it("should call not notify"){ notify_once }
    end

    context "when filter does not return a previous notification" do
      let(:filter){ { user_id: (notification.user.id + 1) } }
      before do
        Notification.should_receive(:notify).with(notification.template_name, notification.user, {})
      end
      it("should call notify"){ notify_once }
    end
  end

end
