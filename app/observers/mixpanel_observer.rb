class MixpanelObserver < ActiveRecord::Observer
  observe :contribution

  def from_waiting_confirmation_to_confirmed(contribution)
    tracker.track(contribution.user.id.to_s, "Contribution confirmed")
  end
  alias :from_pending_to_confirmed :from_waiting_confirmation_to_confirmed

  def from_pending_to_waiting_confirmation(contribution)
    user = contribution.user

    tracker.track(user.id.to_s, "Finished contribution", {
      user_id: user.id.to_s,
      created: user.created_at,
      last_login: user.last_sign_in_at,
      contributions: user.total_contributed_projects,
      has_contributions: (user.total_contributed_projects > 0),
      project: contribution.project.name,
      payment_method: contribution.payment_method,
      payment_choice: contribution.payment_choice
    })
  end

  private
  def tracker
    @tracker ||= Mixpanel::Tracker.new(CatarseSettings[:mixpanel_token])
  end
end


