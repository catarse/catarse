require 'rails_helper'

RSpec.describe PendingContributionWorker do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:contribution) { create(:contribution, state: 'pending', project_id: project.id, user_id: user.id) }
  let(:confirmed_contribution) { create(:contribution, state: 'confirmed', project_id: project.id, user_id: user.id) }

  before do
    Sidekiq::Testing.inline!
  end

  context "when contribution is pending" do
    it "should create a pending payment notification" do
      PendingContributionWorker.perform_async(contribution.id)
      expect(ContributionNotification.where({
        template_name: 'pending_payment', 
        user: contribution.user, 
        contribution: contribution
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

  context "whe contribution is not pending" do
    let(:contribution) { create(:contribution, state: 'confirmed', project_id: project.id, user_id: user.id) }

    it "should not create a pending payment notification" do
      PendingContributionWorker.perform_async(contribution.id)
      expect(ContributionNotification.where({
        template_name: 'pending_payment', 
        user: contribution.user, 
        contribution: contribution
      }).count(:all)).to eq 0
    end
  end


end
