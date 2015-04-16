class MixpanelObserver < ActiveRecord::Observer
  observe :contribution, :project, :project_budget, :project_post, :user, :reward, :payment

  def from_pending_to_paid(payment)
    user = payment.user
    properties = user_properties(user).merge({
      project: payment.project.name,
      payment_method: payment.try(:gateway),
      payment_choice: payment.payment_method,
      referral: payment.contribution.referal_link,
      anonymous: payment.contribution.anonymous,
      value: payment.contribution.value,
      project_goal: payment.project.goal,
      project_online_date: payment.project.online_date,
      project_expires_at: payment.project.expires_at,
      reward_id: payment.contribution.reward_id,
      reward_value: payment.contribution.reward.try(:minimum_value),
      project_address_city: payment.project.account.try(:address_city),
      project_address_state: payment.project.account.try(:address_state),
      account_entity_type: payment.project.account.try(:entity_type)
    })
    track_event(payment.user, "Engaged with Catarse", properties.merge(action: 'contribution confirmed'))
    track_event(payment.user, "Contribution confirmed", properties)
  end

  def after_update(record)
    # Detect project changes
    if record.kind_of?(Project) && record.online? && record.changed?
      [:video_url, :about_html, :headline, :uploaded_image].each do |attribute|
        track_project_owner_engagement(record.user, "Updated #{attribute}") if record.send("#{attribute}_changed?")
      end
    end

    # Detect project owner profile changes
    if record.kind_of?(User) && record.has_online_project? && record.changed?
      if %w[name about_html uploaded_image twitter facebook_link other_link].any?{|attr| record.send("#{attr}_changed?") }
        track_project_owner_engagement(record, 'Updated profile')
      end
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

    # Detect project state changes to update people database
    if record.kind_of?(Project) && record.state_changed?
      update_user_profile(record.user, user_properties(record.user))
    end
  end

  private
  def track_project_owner_engagement(user, action)
    track_event(user, "Project owner engaged with Catarse", user_properties(user).merge(action: action))
  end

  def track_event(user, event, properties={}, ip=nil)
    tracker.track(user.id.to_s, event, properties, user.current_sign_in_ip)
    update_user_profile(user, properties)
  end

  def update_user_profile(user, properties)
    tracker.people.set(user.id.to_s, properties, user.current_sign_in_ip)
  end

  def user_properties(user)
    {
      user_id: user.id.to_s,
      created: user.created_at,
      last_login: user.last_sign_in_at,
      contributions: user.total_contributed_projects,
      has_contributions: (user.total_contributed_projects > 0),
      created_projects: user.projects.count,
      published_projects: user.published_projects.count,
      has_online_project: user.has_online_project?
    }
  end

  def tracker
    @tracker ||= Mixpanel::Tracker.new(CatarseSettings[:mixpanel_token])
  end
end


