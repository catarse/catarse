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
    if record.kind_of?(Project) && record.online? && record.changed?
      [:video_url, :about, :headline, :uploaded_image].each do |attribute|
        track_project_owner_engagement(record.user, "Updated #{attribute}") if record.send("#{attribute}_changed?")
      end
    end

    # Detect project owner profile changes
    if record.kind_of?(User) && record.has_online_project? && record.changed?
      track_project_owner_engagement(record, 'Updated profile')
    end
  end

  def after_create(record)
    # Detect project_post creation
    if record.kind_of?(ProjectPost) && record.project.online? && record.changed?
      track_project_owner_engagement(record.project.user, 'Created post')
    end
  end

  def after_save(record)
    # Detect budget changes
    if record.kind_of?(ProjectBudget) && record.project.online? && record.changed?
      track_project_owner_engagement(record.project.user, 'Updated budget')
    end

    # Detect reward changes
    if record.kind_of?(Reward) && record.project.online? && record.changed?
      track_project_owner_engagement(record.project.user, 'Updated reward')
    end
  end

  private
  def track_project_owner_engagement(user, action)
    tracker.track(user.id.to_s, "Project owner engaged with Catarse", user_properties(user).merge(action: action))
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


