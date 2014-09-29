class ProjectObserver < ActiveRecord::Observer
  observe :project

  def after_save(project)
    if project.try(:video_url_changed?)
      ProjectDownloaderWorker.perform_async(project.id)
    end

    if project.try(:online_date_changed?) && project.online_date.present? && project.in_analysis?
      project.remove_scheduled_job('ProjectSchedulerWorker')
      ProjectSchedulerWorker.perform_at(project.online_date, project.id)
    end
  end

  def after_create(project)
    deliver_default_notification_for(project, :project_received)
    InactiveDraftWorker.perform_at(1.day.from_now, project.id)
  end

  def from_draft_to_in_analysis(project)
    project.notify_to_backoffice(:new_draft_project, {
      from_email: project.user.email,
      from_name: project.user.display_name
    }, project.new_draft_recipient)

    deliver_default_notification_for(project, :in_analysis_project)

    project.update_attributes({ sent_to_analysis_at: DateTime.now })
  end

  def from_online_to_waiting_funds(project)
    project.notify_owner(:project_in_waiting_funds, { from_email: CatarseSettings[:email_projects] })
  end

  def from_waiting_funds_to_successful(project)
    project.notify_owner(:project_success, from_email: CatarseSettings[:email_projects])

    notify_admin_that_project_reached_deadline(project)
    notify_admin_that_project_is_successful(project)
    notify_users(project)
  end

  def notify_admin_that_project_reached_deadline(project)
    project.notify_to_backoffice(:adm_project_deadline, { from_email: CatarseSettings[:email_system] })
  end

  def notify_admin_that_project_is_successful(project)
    redbooth_user = User.find_by(email: CatarseSettings[:email_redbooth])
    project.notify_once(:redbooth_task, redbooth_user) if redbooth_user
  end

  def from_in_analysis_to_rejected(project)
    project.update_attributes({ rejected_at: DateTime.now })
    deliver_default_notification_for(project, :project_rejected)
  end

  def from_in_analysis_to_draft(project)
    project.update_attributes({ sent_to_draft_at: DateTime.now })
  end

  def from_in_analysis_to_online(project)
    deliver_default_notification_for(project, :project_visible)
    project.update_attributes({
      online_date: DateTime.now,
      audited_user_name: project.user.full_name,
      audited_user_cpf: project.user.cpf,
      audited_user_moip_login: project.user.moip_login,
      audited_user_phone_number: project.user.phone_number
    })
  end

  def from_online_to_failed(project)
    notify_users(project)

    project.contributions.with_state('waiting_confirmation').each do |contribution|
      contribution.notify_to_contributor(:pending_contribution_project_unsuccessful)
    end

    request_refund_for_failed_project(project)

    project.notify_owner(:project_unsuccessful, { from_email: CatarseSettings[:email_projects] })
  end

  def from_waiting_funds_to_failed(project)
    from_online_to_failed(project)
    notify_admin_that_project_reached_deadline(project)
  end

  # TODO: we need to remove these comments when
  # we go generate automatic request refund when project fails
  def notify_users(project)
    project.contributions.with_state('confirmed').each do |contribution|
      unless contribution.notified_finish
        template_name = if project.successful?
                          :contribution_project_successful
                        else #if (contribution.credits? || contribution.slip_payment?)
                          if contribution.is_pagarme?
                            if contribution.is_credit_card
                              :contribution_project_unsuccessful_credit_card
                            else
                              :contribution_project_unsuccessful_slip
                            end
                          else
                            :contribution_project_unsuccessful
                          end
                        #elsif contribution.is_paypal? || contribution.is_credit_card?
                        #  :contribution_project_unsuccessful_credit_card
                        #else
                        #  :automatic_refund
                        end

        contribution.notify_to_contributor(template_name)
        contribution.update_attributes({ notified_finish: true })
      end
    end
  end

  private

  # TODO: uncomment when we use automatic
  # request refund when project fails
  def request_refund_for_failed_project(project)
    #project.contributions.avaiable_to_automatic_refund.each do |contribution|
    project.contributions.with_state('confirmed').where(payment_method: 'Pagarme').each do |contribution|
      contribution.request_refund
    end
  end

  def deliver_default_notification_for(project, notification_type)
    template_name = project.notification_type(notification_type)

    project.notify_owner(
      template_name,
      {
        from_email: project.last_channel.try(:email) || CatarseSettings[:email_projects],
        from_name: project.last_channel.try(:name) || CatarseSettings[:company_name]
      }
    )
  end
end
