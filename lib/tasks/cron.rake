# frozen_string_literal: true

require 'zendesk_api'
namespace :cron do
  desc 'Tasks that should run hourly'
  task hourly: %i[finish_projects second_slip_notification second_pix_notification
                  schedule_reminders sync_fb_friends]

  desc 'Tasks that should run daily'
  task daily: %i[notify_delivery_confirmation notify_owners_of_deadline notify_project_owner_about_new_confirmed_contributions notify_unanswered_surveys
                 notify_delivery_approaching
                 notify_late_delivery
                 notify_sub_reports
                 verify_pagarme_transactions notify_new_follows
                 verify_pagarme_transfers verify_pagarme_user_transfers notify_pending_refunds request_direct_refund_for_failed_refund notify_expiring_rewards
                 update_fb_users]

  desc 'Request refund for failed credit card refunds'
  task request_direct_refund_for_failed_refund: :environment do
    ContributionDetail.where("state in ('pending', 'paid') and project_state = 'failed' and lower(gateway) = 'pagarme' and lower(payment_method) = 'cartaodecredito'").each do |c|
      c.direct_refund
      puts "request refund for gateway_id -> #{c.gateway_id}"
    end
  end

  desc 'Update zendesk data'
  task update_zendesk: :environment do

    client = ZendeskAPI::Client.new do |config|
      # Mandatory:

      config.url = CatarseSettings[:zendesk_admin_url]

      # Basic / Token Authentication
      config.username = CatarseSettings[:zendesk_admin_username]


      # Choose one of the following depending on your authentication choice
      config.password = CatarseSettings[:zendesk_admin_password]

      # Optional:

      # Retry uses middleware to notify the user
      # when hitting the rate limit, sleep automatically,
      # then retry the request.
      config.retry = true

      # Logger prints to STDERR by default, to e.g. print to stdout:
      require 'logger'
      config.logger = Logger.new(STDOUT)

      # Changes Faraday adapter
      # config.adapter = :patron

      # Merged with the default client options hash
      # config.client_options = { :ssl => false }

      # When getting the error 'hostname does not match the server certificate'
      # use the API at https://yoursubdomain.zendesk.com/api/v2
    end
    User.where('created_at >= ?',Time.current - 1.year).each do |user|
      zendesk_user = client.users.search(query: "email:" + user.email).first
      if zendesk_user
        zendesk_user.user_fields.externalid = user.id
        zendesk_user.save!
      end
    end

  end

  desc 'Notify about approaching deliveries'
  task notify_delivery_approaching: :environment do
    Project.with_deliveries_approaching.find_each(batch_size: 20) do |project|
      puts "notifying about expiring rewards -> #{project.id}"
      project.notify_owner(:delivery_approaching)
    end
  end

  desc 'Notify about late deliveries'
  task notify_late_delivery: :environment do
    Project.with_late_deliveries.find_each(batch_size: 20) do |project|
      puts "notifying about late rewards -> #{project.id}"
      project.notify_owner(:late_delivery)
    end
  end

  desc 'Notify about rewards about to expire'
  task notify_expiring_rewards: :environment do
    FlexibleProject.with_expiring_rewards.find_each(batch_size: 20) do |project|
      puts "notifying about expiring rewards -> #{project.id}"
      project.notify(
        :expiring_rewards,
        project.user
      )
    end
  end

  desc 'Notify contributors about delivery confirmation'
  task notify_delivery_confirmation: :environment do
    Contribution.need_notify_about_delivery_confirmation.each do |contribution|
      contribution.notify_to_contributor(:confirm_delivery)
    end
  end

  desc 'Notify who have not answered the survey after a week'
  task notify_unanswered_surveys: :environment do
    Survey.where(finished_at: nil).each do |survey|
      survey.reward.contributions.where(survey_answered_at: nil).was_confirmed.each do |contribution|
        if !contribution.survey_answered_at && contribution.notifications.where(template_name: 'answer_survey').where("created_at > current_timestamp - '1 week'::interval ").empty?
          contribution.notify(:answer_survey, contribution.user, contribution, {})
        end
      end
    end
  end

  desc 'Add reminder to scheduler'
  task schedule_reminders: :environment do
    ProjectReminder.can_deliver.find_each(batch_size: 20) do |reminder|
      puts "found reminder for user -> #{reminder.user_id} project -> #{reminder.project}"
      project = reminder.project
      project.notify_once(
        'reminder',
        reminder.user,
        project
      )
    end
  end

  desc 'Send second slip notification'
  task second_slip_notification: :environment do
    puts 'sending second slip notification'
    ContributionDetail.slips_past_waiting.no_confirmed_contributions_on_project.each do |contribution_detail|
      contribution_detail.contribution.notify_to_contributor(:contribution_canceled_slip)
    end
  end

  desc 'Send second pix notification'
  task second_pix_notification: :environment do
    puts 'sending second pix notification'
    ContributionDetail.pixs_past_waiting.no_confirmed_contributions_on_project.find_each do |contribution_detail|
      if contribution_detail.contribution.count_contribution_canceled_pix.zero?
        contribution_detail.generate_second_pix
        contribution_detail.contribution.update_column('count_contribution_canceled_pix', 1)
      end
      contribution_detail.contribution.notify_to_contributor(:contribution_canceled_pix)
    end
  end

  desc 'Finish all expired projects'
  task finish_projects: :environment do
    puts 'Finishing projects...'
    Project.to_finish.each do |project|
      CampaignFinisherWorker.perform_async(project.id)
    end
  end

  desc 'Send a notification to all project owners with contributions done...'
  task notify_project_owner_about_new_confirmed_contributions: :environment do
    puts 'Notifying project owners about contributions...'
    Project.in_funding.with_contributions_confirmed_last_day.each do |project|
      # We cannot use notify_owner for it's a notify_once and we need a notify
      project.notify(
        :project_owner_contribution_confirmed,
        project.user
      )
    end
  end

  desc 'Send a notification about new contributions from friends'
  task notify_new_friends_contributions: [:environment] do
    User.where(subscribed_to_friends_contributions: true).with_contributing_friends_since_last_day.distinct.each do |user|
      Notification.notify(
        :new_friends_contributions,
        user,
        projects_friends: user.projects_backed_by_friends_in_last_day.map do |project|
          {
            project_id: project.id,
            friends_ids: user.contributing_friends_since_last_day(project).pluck(:follow_id)
          }
        end
      )
    end
  end

  desc 'Send a notification about new follows'
  task notify_new_follows: [:environment] do
    User.where(subscribed_to_new_followers: true).followed_since_last_day.each do |user|
      Notification.notify(:new_followers, user, user_follow_ids: user.followers_since_last_day.pluck(:id))
    end
  end

  desc 'Send a notification about pending refunds'
  task notify_pending_refunds: [:environment] do
    #Contribution.need_notify_about_pending_refund.each do |contribution|
    #  unless contribution.user.bank_account.present?
    #    contribution.notify(:contribution_project_unsuccessful_slip_no_account,
    #                        contribution.user)
    #  end
    #end
  end

  desc 'send subscription reports'
  task notify_sub_reports: [:environment] do
    SubscriptionProject.with_state(:online).find_each(batch_size: 20) do |project|
      begin
        transitions = project.subscription_transitions.where("common_schema.subscription_status_transitions.created_at between now() - '1 day'::interval and now()")
        if transitions.exists?
          project.notify(:subscription_report, project.user)
        end
      rescue StandardError => e
        Sentry.capture_exception(e, extra: { task: :notify_sub_reports, project_id: project.id })
      end
    end
  end

  desc 'retry send notifications without sendgrid event'
  task retry_send_notifications: [:environment] do
    Queries::NotificationsWithoutSendgridEvent.new.call.each do |notification|
      Notifier.notify(notification)
    end
  end

  desc 'Update all fb users'
  task update_fb_users: [:environment] do
    User.joins(:projects).distinct.where("users.fb_parsed_link~'^pages/\\d+$'").each do |u|
      FbPageCollectorWorker.perform_async(u.id)
    end
  end

  desc 'Refuse boleto payments that are 4 days or more old and not paid'
  task refuse_4_days_more_unpaid_boletos: [:environment] do
    Payment.all_boleto_that_should_be_refused.find_each(batch_size: 20) do |payment|
      payment.update_column('state', 'refused')
      payment.update_column('refused_at', Time.current)
      payment.save!
    end
  end

  desc 'Refuse pix payments that are 4 days or more old and not paid'
  task refuse_4_days_more_unpaid_pixs: [:environment] do
    Payment.all_pix_that_should_be_refused.find_each(batch_size: 20) do |payment|
      payment.update_column('state', 'refused')
      payment.update_column('refused_at', Time.current)
      payment.save!
    end
  end

  desc 'create project fiscal to project flex and aon'
  task create_project_fiscal_to_project_flex_and_aon: :environment do
    Project.joins(:project_fiscals).where(mode: %i[aon flex], state: %i[waiting_funds successful])
      .where("project_fiscals.end_date > ?", Time.zone.now - 2.months).each do |project|
        CreateProjectFiscalToProjectFlexAndAonAction.new(project_id: project.id).call
    end
  end

  desc 'create project fiscal to project sub'
  task create_project_fiscal_to_project_sub: :environment do
    Project.where(mode: %i[sub], state: %i[online]).each do |project|
      CreateProjectFiscalToProjectSubAction.new(project_id: project.id, month: Time.zone.now.month, year: Time.zone.now.year).call
    end

    Project.joins(:project_fiscals).where(mode: %i[sub], state: %i[successful])
      .where("project_fiscals.end_date > ?", Time.zone.now - 2.months).each do |project|
        CreateProjectFiscalToProjectSubAction.new(project_id: project.id, month: Time.zone.now.month, year: Time.zone.now.year).call
    end
  end

  desc 'sync FB friends'
  task sync_fb_friends: [:environment] do
    Authorization.where("last_token is not null and updated_at >= current_timestamp - '24 hours'::interval").each do |authorization|
      last_f = UserFriend.where(user_id: authorization.user_id).last
      next if last_f.present? && last_f.created_at > 24.hours.ago

      begin
        koala = Koala::Facebook::API.new(authorization.last_token)
        friends = koala.get_connections('me', 'friends')

        friends.each do |f|
          friend_auth = Authorization.find_by_uid(f['id'])

          next unless friend_auth.present?
          puts "creating friend #{friend_auth.user_id} to user #{authorization.user_id}"
          UserFriend.create({
                              user_id: authorization.user_id,
                              friend_id: friend_auth.user_id
                            })
        end
      rescue Exception => e
        puts "error #{e}"
      end
    end
  end

  desc 'register 100_goal_reached rdevent for projects'
  task rdevent_100_goal_reached: [:environment] do
    Project.joins(:project_total).where("project_totals.progress > 100 and not exists(select true from rdevents r  where r.project_id = projects.id and r.event_name = '100_goal_reached') and projects.state = 'online'").find_each(batch_size: 20) do |project|
      Rdevent.create(
        project_id: project.id,
        user_id: project.user.id,
        event_name: '100_goal_reached'
      )
      puts "[100_goal_reached rdevent] project #{project.id}"
    end
  end
end
