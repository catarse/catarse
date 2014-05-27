require 'spec_helper'

describe MixpanelObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:tracker){ double('mixpanel-ruby tracker', {track: nil}) }

  before do
    MixpanelObserver.any_instance.unstub(:tracker)
    MixpanelObserver.any_instance.stub(tracker: tracker)
  end

  describe "#from_waiting_confirmation_to_confirmed" do
    it "should send tracker a track call with the user id of the contribution" do
      tracker.should_receive(:track).with(contribution.user.id.to_s, "Contribution confirmed", {
        user_id: contribution.user.id.to_s,
        created: contribution.user.created_at,
        last_login: contribution.user.last_sign_in_at,
        contributions: contribution.user.total_contributed_projects,
        has_contributions: (contribution.user.total_contributed_projects > 0),
        project: contribution.project.name,
        payment_method: contribution.payment_method,
        payment_choice: contribution.payment_choice
      })
      contribution.notify_observers :from_waiting_confirmation_to_confirmed
    end
  end

  describe "#from_pending_to_confirmed" do
    it "should send tracker a track call with the user id of the contribution" do
      tracker.should_receive(:track).with(contribution.user.id.to_s, "Contribution confirmed", {
        user_id: contribution.user.id.to_s,
        created: contribution.user.created_at,
        last_login: contribution.user.last_sign_in_at,
        contributions: contribution.user.total_contributed_projects,
        has_contributions: (contribution.user.total_contributed_projects > 0),
        project: contribution.project.name,
        payment_method: contribution.payment_method,
        payment_choice: contribution.payment_choice
      })
      contribution.notify_observers :from_pending_to_confirmed
    end
  end

end


