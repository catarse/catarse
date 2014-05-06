require 'spec_helper'

describe MixpanelObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:tracker){ double('mixpanel-ruby tracker', {track: nil}) }

  before do
    MixpanelObserver.any_instance.unstub(:tracker)
    MixpanelObserver.any_instance.stub(tracker: tracker)
    tracker.should_receive(:track).with(contribution.user.id.to_s, "Contribution confirmed")
  end

  describe "#from_waiting_confirmation_to_confirmed" do
    it "should send tracker a track call with the user id of the contribution" do
      contribution.notify_observers :from_waiting_confirmation_to_confirmed
    end
  end

  describe "#from_pending_to_confirmed" do
    it "should send tracker a track call with the user id of the contribution" do
      contribution.notify_observers :from_pending_to_confirmed
    end
  end
end


