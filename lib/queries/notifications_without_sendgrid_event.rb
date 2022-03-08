# frozen_string_literal: true

module Queries
  class NotificationsWithoutSendgridEvent
    def call
      @notifications = []
      SendgridEvent.distinct.pluck(:notification_type).each do |notification_type|
        list_notifications = find_notifications_without_sendgrid_events(notification_type)

        @notifications += list_notifications if list_notifications.present?
      end
      @notifications
    rescue StandardError => e
      Sentry.capture_exception(e, level: :fatal)
    end

    private

    def find_notifications_without_sendgrid_events(notification_type)
      table_name = notification_type.camelize.singularize.constantize.table_name
      join_conditions = "left outer join sendgrid_events on sendgrid_events.notification_id = #{table_name}.id
        and sendgrid_events.notification_type = '#{notification_type}'"
      notification_type.camelize.singularize.constantize.joins(ActiveRecord::Base.sanitize_sql(join_conditions)).where(
        sendgrid_events: { notification_id: nil }, table_name => { created_at: 5.days.ago..4.hours.ago }
      ).all.to_a
    end
  end
end
