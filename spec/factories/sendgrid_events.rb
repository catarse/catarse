# frozen_string_literal: true

FactoryBot.define do
  factory :sendgrid_event do
    notification_id { Faker::Number.number(digits: 4) }
    notification_user { Faker::Number.number(digits: 4) }
    notification_type { 'ContributionNotification' }
    template_name { 'payment_slip' }
    event { 'delivered' }
    email { Faker::Internet.email }
    useragent { 'Mozilla/5.0 (Windows NT 5.1) ' }
    sendgrid_data { {} }
  end
end
