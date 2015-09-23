namespace :cron do
  desc "Tasks that should run hourly"
  task hourly: [:finish_projects, :second_slip_notification,
                :refresh_materialized_views, :schedule_reminders]

  desc "Tasks that should run daily"
  task daily: [ :notify_project_owner_about_new_confirmed_contributions,
               :deliver_projects_of_week, :verify_pagarme_transactions,
               :verify_pagarme_transfers, :notify_pending_refunds, :request_direct_refund_for_failed_refund]

  desc "Refresh all materialized views"
  task refresh_materialized_views: :environment do
    puts "refreshing views"
    Statistics.refresh_view
    UserTotal.refresh_view
  end

  desc 'Request refund for failed credit card refunds'
  task request_direct_refund_for_failed_refund: :environment do
    ContributionDetail.where("state in ('pending', 'paid') and project_state = 'failed' and lower(gateway) = 'pagarme' and lower(payment_method) = 'cartaodecredito'").each do |c|
      c.direct_refund
      puts "request refund for gateway_id -> #{c.gateway_id}"
    end
  end

  desc 'Add missing reminder jobs'
  task schedule_reminders: :environment do
    ProjectNotification.where("template_name = 'reminder' and sent_at is null and deliver_at >= now()").find_each do |notification|
      has_on_queue = notification.project.exists_on_scheduled_jobs('UserNotifier::EmailWorker', ['ProjectNotification', notification.id])
      puts "#{notification.user.name} ==> #{has_on_queue} => #{notification.to_json}"
      notification.deliver unless has_on_queue
    end
  end

  desc "Send second slip notification"
  task second_slip_notification: :environment do
    puts "sending second slip notification"
    ContributionDetail.slips_past_waiting.no_confirmed_contributions_on_project.each do |contribution_detail|
      contribution_detail.contribution.notify_to_contributor(:contribution_canceled_slip)
    end
  end

  desc "Finish all expired projects"
  task finish_projects: :environment do
    puts "Finishing projects..."
    Project.to_finish.each do |project|
      CampaignFinisherWorker.perform_async(project.id)
    end
  end

  desc "Send a notification to all project owners with contributions done..."
  task notify_project_owner_about_new_confirmed_contributions: :environment do
    puts "Notifying project owners about contributions..."
    Project.in_funding.with_contributions_confirmed_last_day.each do |project|
      # We cannot use notify_owner for it's a notify_once and we need a notify
      project.notify(
        :project_owner_contribution_confirmed,
        project.user
      )
    end
  end

  desc 'Send a notification about pending refunds'
  task notify_pending_refunds: [:environment] do
    Contribution.need_notify_about_pending_refund.each do |contribution|
     contribution.notify(:contribution_project_unsuccessful_slip_no_account,
                         contribution.user) unless contribution.user.bank_account.present?
    end
  end

  desc "Deliver a collection of recents projects of a category"
  task deliver_projects_of_week: :environment do
    puts "Delivering projects of the week..."
    Category.with_projects_on_this_week.each do |category|
      category.deliver_projects_of_week_notification
    end
  end
end
