# frozen_string_literal: true

RSpec.configure do
  random_time_zone = ActiveSupport::TimeZone.all.map(&:name).sample
  puts "SETTING TIMEZONE TO #{random_time_zone}. Called from spec/support/random_timezone.rb"
  Time.zone = random_time_zone # rubocop:disable Rails/TimeZoneAssignment
end
