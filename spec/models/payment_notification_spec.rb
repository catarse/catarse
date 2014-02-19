require 'spec_helper'

describe PaymentNotification do
  describe "Associations" do
    it{ should belong_to :contribution }
  end

  describe "#extra_data" do
    let(:test_hash){{"test_hash" => 1}}
    before do
      @p = PaymentNotification.new(contribution_id: FactoryGirl.create(:contribution).id, extra_data: test_hash)
      @p.save!
    end
    subject{ @p.extra_data }
    it{ should == test_hash }
  end

  describe "#deliver_process_notification" do
    before do
      Notification.unstub(:notify)
      Notification.unstub(:notify_once)

      Notification.should_receive(:notify_once)
    end

    subject do
      create(:payment_notification, contribution: create(:contribution, project: create(:project)))
    end

    it("should notify the contribution"){ subject.deliver_process_notification }
  end

  describe "#deliver_slip_canceled_notification" do
    before do
      Notification.unstub(:notify)
      Notification.unstub(:notify_once)

      Notification.should_receive(:notify_once)
    end

    subject do
      create(:payment_notification, contribution: create(:contribution, project: create(:project)))
    end

    it("should notify the contribution"){ subject.deliver_slip_canceled_notification }
  end

end
