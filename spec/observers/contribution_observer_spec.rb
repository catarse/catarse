require 'rails_helper'

RSpec.describe ContributionObserver do
  let(:contribution){ create(:contribution, project: project) }

  subject{ contribution }

  describe "after_create" do
    context "when project expires_at less than 2 days in the future" do
      let(:project){ create_project({online_days: 2}, {to_state: 'online', created_at: Time.now - 1.day}) }

      before do
        expect(PendingContributionWorker).to_not receive(:perform_at)
      end

      it "should not call perform at in pending contribution worker" do
        contribution.save
      end
    end

    context "when project expires_at is 2 days in the future" do
      let(:project){ create_project({online_days: 3}, {to_state: 'online', created_at: Time.now}) }

      before do
        expect(PendingContributionWorker).to receive(:perform_at)
      end

      it "should call perform at in pending contribution worker" do
        contribution.save
      end
    end

  end

end

