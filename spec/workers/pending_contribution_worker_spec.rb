require 'rails_helper'

RSpec.describe PendingContributionWorker do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:contribution) { create(:pending_contribution, project_id: project.id, user_id: user.id) }
  let(:contribution_no_payments) { create(:contribution, project_id: project.id, user_id: user.id) }
  let(:confirmed_contribution) { create(:confirmed_contribution, project_id: project.id, user_id: user.id) }

  before do
    Sidekiq::Testing.inline!
  end

  context "when contribution is pending" do
    it "should not create a pending payment notification" do
      PendingContributionWorker.perform_async(contribution.id)
      expect(ContributionNotification.where({
        template_name: 'pending_payment', 
        user: contribution.user, 
        contribution: contribution
      }).count(:all)).to eq 0
    end
  end

  context "when contribution has no payment" do
    it "should create a pending payment notification" do
      PendingContributionWorker.perform_async(contribution_no_payments.id)
      expect(ContributionNotification.where({
        template_name: 'pending_payment', 
        user: contribution_no_payments.user, 
        contribution: contribution_no_payments
      }).count(:all)).to eq 1
    end
  end

  context "when contribution is pending but we have a confirmed contribution on the same project" do
    before do
      confirmed_contribution
    end

    it "should not create a pending payment notification" do
      PendingContributionWorker.perform_async(contribution.id)
      expect(ContributionNotification.where({
        template_name: 'pending_payment', 
        user: contribution.user, 
        contribution: contribution
      }).count(:all)).to eq 0
    end
  end

  context "when contribution is not pending" do
    before do
      allow_any_instance_of(ContributionObserver).to receive(:after_create)
    end

    it "should not create a pending payment notification" do
      PendingContributionWorker.perform_async(confirmed_contribution.id)

      expect(ContributionNotification.where({
        template_name: 'pending_payment', 
        user: confirmed_contribution.user, 
        contribution: confirmed_contribution
      }).count(:all)).to eq 0
    end
  end


end
