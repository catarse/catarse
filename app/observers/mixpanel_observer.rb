class MixpanelObserver < ActiveRecord::Observer
  observe :contribution

  def from_waiting_confirmation_to_confirmed(contribution)
    user = contribution.user
    properties = {
      user_id: user.id.to_s,
      created: user.created_at,
      last_login: user.last_sign_in_at,
      contributions: user.total_contributed_projects,
      has_contributions: (user.total_contributed_projects > 0),
      project: contribution.project.name,
      payment_method: contribution.payment_method,
      payment_choice: contribution.payment_choice,
      referral: contribution.referal_link
    }
    tracker.track(contribution.user.id.to_s, "Engaged with Catarse", properties.merge(action: 'contribution confirmed'))
    tracker.track(contribution.user.id.to_s, "Contribution confirmed", properties)
  end
  alias :from_pending_to_confirmed :from_waiting_confirmation_to_confirmed

  private
  def tracker
    @tracker ||= Mixpanel::Tracker.new(CatarseSettings[:mixpanel_token])
  end
end


