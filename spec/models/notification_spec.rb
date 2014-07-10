require 'spec_helper'

describe Notification do
  let(:contribution){ create(:contribution) }
  let(:notification){ create(:notification, template_name: 'project_success', dismissed: false) }

  before do
    Notification.unstub(:notify)
    Notification.unstub(:notify_once)
    ActionMailer::Base.deliveries.clear
  end

  describe "Associations" do
    it{ should belong_to :user }
    it{ should belong_to :project }
    it{ should belong_to :contribution }
    it{ should belong_to :project_post }
  end

  describe ".last_with_template" do
    before do
      create(:notification)
      notification
      create(:notification, template_name: 'project_failed')
    end

    subject{ Notification.last_with_template(:project_success) }

    it{ should == notification }
  
  end

  describe "#deliver" do
    let(:deliver_exception){ nil }

    before do
      NotificationWorker.jobs.clear
      deliver_exception
      notification.deliver
    end

    context "when dismissed is true" do
      let(:notification){ create(:notification, dismissed: true) }
      it("should not add the notification into queue") { NotificationWorker.jobs.should be_empty }
    end

    context "when dismissed is false" do
      it("should add the notification into queue") { NotificationWorker.jobs.should_not be_empty }
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
        origin_email: CatarseSettings['email_contact'],
        origin_name: CatarseSettings[:company_name]
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
