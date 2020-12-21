RSpec.configure do |config|
  random_time_zone = ActiveSupport::TimeZone.all.map(&:name).sample
  puts "SETTING TIMEZONE TO #{random_time_zone}. Called from spec/support/random_timezone.rb"
  Time.zone = random_time_zone
end
