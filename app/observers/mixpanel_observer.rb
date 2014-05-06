class MixpanelObserver < ActiveRecord::Observer
  observe :contribution

  def from_waiting_confirmation_to_confirmed(contribution)
    tracker.track(contribution.user.id.to_s, "Contribution confirmed")
  end
  alias :from_pending_to_confirmed :from_waiting_confirmation_to_confirmed

  private
  def tracker
    @tracker ||= Mixpanel::Tracker.new(CatarseSettings[:mixpanel_token])
  end
end


