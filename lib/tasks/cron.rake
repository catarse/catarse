namespace :cron do
  desc "Tasks that should run hourly"
  task hourly: [:finish_projects, :cancel_expired_waiting_confirmation_contributions]

  desc "Tasks that should run daily"
  task daily: [:update_payment_service_fee, :notify_project_owner_about_new_confirmed_contributions, :move_pending_contributions_to_trash, :deliver_projects_of_week]

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
    Project.with_contributions_confirmed_today.each do |project|
      project.notify_owner(
        :project_owner_contribution_confirmed
      )
    end
  end

  desc "Move to deleted state all contributions that are in pending a lot of time"
  task :move_pending_contributions_to_trash => [:environment] do
    puts "Moving pending contributions to trash..."
    Contribution.where("state in('pending') and created_at + interval '6 days' < current_timestamp").update_all({state: 'deleted'})
  end

  desc "Cancel all waiting_confirmation contributions that is passed 4 weekdays"
  task :cancel_expired_waiting_confirmation_contributions => :environment do
    puts "Cancel waiting_confirmation contributions older than 4 working days..."
    Contribution.can_cancel.update_all(state: 'canceled')
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
