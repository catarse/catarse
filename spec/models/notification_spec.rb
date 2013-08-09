require 'spec_helper'

describe Notification do
  let(:backer){ create(:backer) }
  let(:notification_type){ create(:notification_type, name: 'confirm_backer') }

  before do
    Notification.unstub(:create_notification)
    Notification.unstub(:create_notification_once)
    ActionMailer::Base.deliveries.clear
  end

  describe "Associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
    it{ should belong_to :notification_type }
    it{ should belong_to :backer }
    it{ should belong_to :project_update }
  end

  describe "#send_email" do
    let(:deliver_exception){ nil }
    let(:notification){ create(:notification, dismissed: false, notification_type: notification_type) }

    before do
      deliver_exception
      notification.send_email
    end

    #temporarily disabled
    #context "when deliver raises and exception" do
      #let(:deliver_exception){ NotificationsMailer.stub(:notify).and_raise('fake error') }
      #it("should not dismiss the notification"){ notification.dismissed.should be_false }
    #end

    context "when dismissed is true" do
      let(:notification){ create(:notification, dismissed: true, notification_type: notification_type) }
      it("should not send email"){ ActionMailer::Base.deliveries.should be_empty }
    end

    context "when dismissed is false" do
      it("should send email"){ ActionMailer::Base.deliveries.should_not be_empty }
      it("should dismiss the notification"){ notification.dismissed.should be_true }
    end
  end

  describe ".create_notification_once" do
    let(:create_notification_once){ Notification.create_notification_once(:confirm_backer, backer.user, {user_id: backer.user.id, backer_id: backer.id}, backer: backer,  project_name: backer.project.name) }
    before{ notification_type }

    context "when I have not created the notification with the same type and filters" do
      before do
        Notification.should_receive(:create_notification)
      end
      it("should call create_notification"){ create_notification_once }
    end

    context "when I have already created the notification with the same type but a partially different filter" do
      before do
        create_notification_once
        Notification.should_receive(:create_notification)
      end
      it("should call create_notification"){  Notification.create_notification_once(:confirm_backer, backer.user, {user_id: backer.user.id, backer_id: 0}, backer: backer,  project_name: backer.project.name) }
    end
    context "when I have already created the notification with the same type and filters" do
      before do
        create_notification_once
        Notification.should_receive(:create_notification).never
      end
      it("should never call create_notification"){ create_notification_once }
    end
  end

  describe ".create_notification" do
    subject{ Notification.create_notification(:confirm_backer, backer.user, backer: backer,  project_name: backer.project.name) }

    context "when NotificationType with the provided name exists" do
      before{ notification_type }
      it{ should be_persisted }
      its(:class){ should == Notification }
    end

    context "when NotificationType with the provided name does not exist" do
      it{ should be_nil }
    end

    context "when an update is provided" do
      let(:update){ create(:update) }
      before{ notification_type }
      subject{ Notification.create_notification(:confirm_backer, backer.user, update: update, backer: backer,  project_name: backer.project.name) }
      it{ should be_persisted }
      its(:project_update){ should == update }
    end
  end

  describe ".notify_backer" do
    before{ notification_type }

    context "when NotificationType with the provided name exists" do
      subject{ Notification.create_notification(:confirm_backer, backer.user, backer: backer,  project_name: backer.project.name) }
      its(:dismissed){ should be_true }
      its(:backer){ should == backer }
    end
  end
end
