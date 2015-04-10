require 'rails_helper'

RSpec.describe ContributionObserver do
  let(:contribution){ create(:contribution) }

  subject{ contribution }

  describe "after_create" do
    before do
      expect(PendingContributionWorker).to receive(:perform_at)
    end

    it "should call perform at in pending contribution worker" do
      contribution.save
    end

  end

end

