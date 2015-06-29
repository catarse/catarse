namespace :cron do
  desc "Tasks that should run hourly"
  task hourly: [:finish_projects,
                :cancel_expired_waiting_confirmation_contributions,
                :refresh_materialized_views]

  desc "Tasks that should run daily"
  task daily: [:refresh_materialized_views,
               :notify_project_owner_about_new_confirmed_contributions,
               :deliver_projects_of_week, :verify_pagarme_transactions,
               :verify_pagarme_transfers]

  desc "Refresh all materialized views"
  task refresh_materialized_views: :environment do
    puts "refreshing views"
    Statistics.refresh_view
  end


  desc "Refresh all materialized views"
  task refresh_materialized_views: :environment do
    puts "refreshing views"
    Statistics.refresh_view
    UserTotal.refresh_view
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
    Payment.move_to_trash
  end

  desc "Deliver a collection of recents projects of a category"
  task deliver_projects_of_week: :environment do
    puts "Delivering projects of the week..."
    if Time.current.monday?
      Category.with_projects_on_this_week.each do |category|
        category.deliver_projects_of_week_notification
      end
    end
  end
end
