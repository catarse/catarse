require 'rails_helper'

RSpec.describe MixpanelObserver do
  let(:contribution){ create(:contribution, key: 'should be updated', payment_method: 'should be updated', state: 'confirmed', confirmed_at: nil) }
  let(:tracker){ double('mixpanel-ruby tracker', {track: nil}) }
  let(:properties) do 
    {
      user_id: contribution.user.id.to_s,
      created: contribution.user.created_at,
      last_login: contribution.user.last_sign_in_at,
      contributions: contribution.user.total_contributed_projects,
      has_contributions: (contribution.user.total_contributed_projects > 0),
      project: contribution.project.name,
      payment_method: contribution.payment_method,
      payment_choice: contribution.payment_choice,
      referral: contribution.referal_link
    }
  end

  before do
    allow_any_instance_of(MixpanelObserver).to receive(:tracker).and_call_original
    allow_any_instance_of(MixpanelObserver).to receive_messages(tracker: tracker)
  end

  describe "#from_waiting_confirmation_to_confirmed" do
    it "should send tracker a track call with the user id of the contribution" do
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Engaged with Catarse", properties.merge(action: 'contribution confirmed'))
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Contribution confirmed", properties)
      contribution.notify_observers :from_waiting_confirmation_to_confirmed
    end
  end

  describe "#from_pending_to_confirmed" do
    it "should send tracker a track call with the user id of the contribution" do
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Engaged with Catarse", properties.merge(action: 'contribution confirmed'))
      expect(tracker).to receive(:track).with(contribution.user.id.to_s, "Contribution confirmed", properties)
      contribution.notify_observers :from_pending_to_confirmed
    end
  end

end


