require 'spec_helper'

describe PendingContributionWorker do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:contribution) { create(:contribution, state: 'pending', project_id: project.id, user_id: user.id) }
  let(:confirmed_contribution) { create(:contribution, state: 'confirmed', project_id: project.id, user_id: user.id) }

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

  context "when contribution is pending but we have a confirmed contribution on the same project" do
    before do
      confirmed_contribution
      Notification.should_not_receive(:notify_once).with(
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
