# frozen_string_literal: true

class ProjectObserver < ActiveRecord::Observer
  observe :project

  def before_save(project)
    if project.try(:online_days_changed?) || project.try(:expires_at).nil?
      project.update_expires_at
    end

    unless project.permalink.present?
      project.permalink = "#{project.name.parameterize.tr('-', '_')}_#{SecureRandom.hex(2)}"
    end

    project.video_embed_url = project.video_valid? ? project.video.embed_url : nil
  end

  def after_save(project)
    if project.try(:video_url_changed?)
      ProjectDownloaderWorker.perform_async(project.id)
    end
  end

  def from_waiting_funds_to_successful(project)
    notify_admin_that_project_is_successful(project)
    notify_users(project)
    project.notify_owner(:project_success)
    [15, 30, 60, 90].each do |day|
      project.notify(:project_success, project.user, project, {deliver_at: Time.now + day.days})
    end
  end
  alias from_online_to_successful from_waiting_funds_to_successful

  def from_draft_to_online(project)
    project.update_expires_at
    project.update_attributes(
      published_ip: project.user.current_sign_in_ip,
      audited_user_name: project.user.name,
      audited_user_cpf: project.user.cpf,
      audited_user_phone_number: project.user.phone_number
    )

    UserBroadcastWorker.perform_async(
      follow_id: project.user_id,
      template_name: 'follow_project_online',
      project_id: project.id
    )

    FacebookScrapeReloadWorker.perform_async(project.direct_url)
  end

  def from_online_to_draft(project)
    refund_all_payments(project)
  end

  def from_successful_to_rejected(project)
    BalanceTransaction.insert_project_refund_contributions(project.id)
    refund_all_payments(project)
    project.notify_owner(:project_canceled)
  end

  def from_online_to_rejected(project)
    refund_all_payments(project)
    project.notify_owner(:project_canceled) if project.rejected?
  end
  alias from_waiting_funds_to_rejected from_online_to_rejected
  alias from_waiting_funds_to_failed from_online_to_rejected
  alias from_online_to_deleted from_online_to_rejected
  alias from_online_to_failed from_online_to_rejected

  private

  def notify_admin_that_project_is_successful(project)
    redbooth_user = User.find_by(email: CatarseSettings[:email_redbooth])
    project.notify_once(:redbooth_task, redbooth_user) if redbooth_user
  end

  def notify_users(project)
    project.payments.with_state('paid').each do |payment|
      if project.successful?
        payment.contribution.
          notify_to_contributor(
            :contribution_project_successful)
      end
    end
  end

  def refund_all_payments(project)
    project.payments.with_state('paid').each do |payment|
      payment.direct_refund
    end
  end
end
