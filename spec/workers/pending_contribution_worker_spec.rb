require 'spec_helper'

describe PendingContributionWorker do
  let(:contribution) { create(:contribution, state: 'pending') }

  before do
    Sidekiq::Testing.inline!
  end

  context "when contribution is pending" do
    before do
      Notification.should_receive(:notify_once).with(
        :pending_payment,
        contribution.user,
        { contribution_id: contribution.id },
        contribution: contribution
      )
    end

    it "should create a pending payment notification" do
      PendingContributionWorker.perform_async(contribution.id)
    end
  end

  context "whe contribution is not pending" do
    before do
      contribution.stub(:pending?).and_return(false)

      Notification.any_instance.should_not_receive(:notify_once).with(
        :pending_payment,
        contribution.user,
        { contribution_id: contribution.id },
        contribution: contribution
      )
    end

    it "should not create a pending payment notification" do
      PendingContributionWorker.perform_async(contribution.id)
    end
  end


end
