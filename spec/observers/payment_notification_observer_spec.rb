require 'spec_helper'

describe PaymentNotificationObserver do
  describe 'before_save' do
    before do
      Notification.unstub(:notify)
      Notification.unstub(:notify_once)
    end

    context "when payment is being processed" do
      before do
        Notification.should_receive(:notify_once)
        p = create(:payment_notification)
        p.extra_data = {'status_pagamento' => '6'}
        p.contribution.project = create(:project)
        p.save!
      end
      it("should notify the contribution"){ p }
    end

    context "when payment is approved" do
      before do
        Notification.should_receive(:notify_once).never
        p = create(:payment_notification)
        p.extra_data = {'status_pagamento' => '1'}
        p.contribution.project = create(:project)
        p.save!
      end
      it("should not notify the contribution"){ p }
    end

  end
end
