  # Google analytics ID
  GA.tracker = Configuration['google_analytics_id'] if Rails.env.production? && Configuration['google_analytics_id'].present?

