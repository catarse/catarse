require 'rails_helper'

RSpec.describe ContributionObserver do
  let(:contribution){ create(:contribution, project: project) }

  subject{ contribution }

  describe "after_create" do
    context "when project expires_at less than 2 days in the future" do
      let(:project){ create(:project, online_date: Time.now, online_days: 1) }

      before do
        expect(PendingContributionWorker).to_not receive(:perform_at)
      end

      it "should not call perform at in pending contribution worker" do
        contribution.save
      end
    end

    context "when project expires_at is 2 days in the future" do
      let(:project){ create(:project, online_date: Time.now, online_days: 3) }

      before do
        expect(PendingContributionWorker).to receive(:perform_at)
      end

      it "should call perform at in pending contribution worker" do
        contribution.save
      end
    end

  end

end

