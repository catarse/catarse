namespace :cron do
  desc "Tasks that should run hourly"
  task hourly: [:finish_projects, :cancel_expired_waiting_confirmation_contributions]

  desc "Tasks that should run daily"
  task daily: [:update_payment_service_fee, :notify_project_owner_about_new_confirmed_contributions, :deliver_projects_of_week, :verify_pagarme_transactions]

  desc "Finish all expired projects"
  task finish_projects: :environment do
    puts "Finishing projects..."
    Project.to_finish.each do |project|
      CampaignFinisherWorker.perform_async(project.id)
    end
  end

  desc "update paypal contributions without a payment_service_fee"
  task update_payment_service_fee: :environment do
    puts "Updating payment service fee..."
    ActiveRecord::Base.connection.execute(<<-EOQ)
    UPDATE contributions SET payment_service_fee = ((regexp_matches(pn.extra_data, 'fee_amount":"(\d*\.\d*)"'))[1])::numeric from payment_notifications pn where contributions.id = pn.contribution_id AND contributions.payment_service_fee is null and contributions.payment_method = 'PayPal' and contributions.state = 'confirmed' and pn.extra_data ~* 'fee_amount';
    EOQ
  end

  desc "Send a notification to all project owners with contributions done..."
  task notify_project_owner_about_new_confirmed_contributions: :environment do
    puts "Notifying project owners about contributions..."
    Project.with_contributions_confirmed_last_day.each do |project|
      # We cannot use notify_owner for it's a notify_once and we need a notify
      project.notify(
        :project_owner_contribution_confirmed,
        project.user
      )
    end
  end

  desc "Cancel all pending payments older than 1 week"
  task :cancel_expired_waiting_confirmation_contributions => :environment do
    puts "Cancel all pending payments older than 1 week"
    Payment.can_delete.update_all(state: 'deleted')
  end

  desc "Deliver a collection of recents projects of a category"
  task deliver_projects_of_week: :environment do
    puts "Delivering projects of the week..."
    if Time.now.in_time_zone(Time.zone.tzinfo.name).monday?
      Category.with_projects_on_this_week.each do |category|
        category.deliver_projects_of_week_notification
      end
    end
  end
end
