class MixpanelObserver < ActiveRecord::Observer
  observe :contribution, :project, :project_budget, :project_post, :user

  def from_waiting_confirmation_to_confirmed(contribution)
    user = contribution.user
    properties = user_properties(user).merge({
      project: contribution.project.name,
      payment_method: contribution.payment_method,
      payment_choice: contribution.payment_choice,
      referral: contribution.referal_link
    })
    tracker.track(contribution.user.id.to_s, "Engaged with Catarse", properties.merge(action: 'contribution confirmed'))
    tracker.track(contribution.user.id.to_s, "Contribution confirmed", properties)
  end
  alias :from_pending_to_confirmed :from_waiting_confirmation_to_confirmed

  def after_update(record)
    # Detect project changes
    if record.class == Project && record.state == 'online' && record.changed?
      user = record.user
      track_project_owner_engagement(user, 'Updated video') if record.video_url_changed?
      track_project_owner_engagement(user, 'Updated about') if record.about_changed?
      track_project_owner_engagement(user, 'Updated headline') if record.headline_changed?
      track_project_owner_engagement(user, 'Updated image') if record.uploaded_image_changed?
    end

    # Detect project owner profile changes
    if record.class == User && record.has_online_project? && record.changed?
      track_project_owner_engagement(record, 'Updated profile')
    end
  end

  def after_create(record)
    # Detect project_post creation
    if record.class == ProjectPost && record.project.state == 'online' && record.changed?
      track_project_owner_engagement(record.project.user, 'Created post')
    end
  end

  def after_save(record)
    # Detect budget changes
    if record.class == ProjectBudget && record.project.state == 'online' && record.changed?
      track_project_owner_engagement(record.project.user, 'Updated budget')
    end

    # Detect reward changes
    if record.class == Reward && record.project.state == 'online' && record.changed?
      track_project_owner_engagement(record.project.user, 'Updated reward')
    end
  end

  private
  def track_project_owner_engagement(user, action)
    tracker.track(user.id, "Project owner engaged with Catarse", user_properties(user).merge(action: action))
  end

  def user_properties(user)
    {
      user_id: user.id.to_s,
      created: user.created_at,
      last_login: user.last_sign_in_at,
      contributions: user.total_contributed_projects,
      has_contributions: (user.total_contributed_projects > 0)
    }
  end

  def tracker
    @tracker ||= Mixpanel::Tracker.new(CatarseSettings[:mixpanel_token])
  end
end


