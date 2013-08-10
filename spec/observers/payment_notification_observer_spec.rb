require 'spec_helper'

describe PaymentNotificationObserver do
  describe 'before_save' do
    before do
      Notification.unstub(:create_notification)
      Notification.unstub(:create_notification_once)
      create(:notification_type, name: 'processing_payment')
    end

    context "when payment is being processed" do
      before do
        Notification.should_receive(:create_notification_once)
        p = create(:payment_notification)
        p.extra_data = {'status_pagamento' => '6'}
        p.backer.project = create(:project)
        p.save!
      end
      it("should notify the backer"){ p }
    end

    context "when payment is approved" do
      before do
        Notification.should_receive(:create_notification_once).never
        p = create(:payment_notification)
        p.extra_data = {'status_pagamento' => '1'}
        p.backer.project = create(:project)
        p.save!
      end
      it("should not notify the backer"){ p }
    end

  end
end
