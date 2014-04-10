  # Google analytics ID
  GA.tracker = CatarseSettings['google_analytics_id'] if Rails.env.production? && CatarseSettings['google_analytics_id'].present?

