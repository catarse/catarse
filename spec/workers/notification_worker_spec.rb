require 'spec_helper'

describe NotificationWorker do
  let(:notification) { create(:notification, dismissed: false)}
  let(:perform_async) { NotificationWorker.perform_async(notification.id)}

  before do
    Sidekiq::Testing.inline!

    NotificationsMailer.should_receive(:notify).with(notification).and_call_original
    Notification.any_instance.should_receive(:update_attributes)
  end

  it "should satisfy expectations" do
    perform_async
  end
end
