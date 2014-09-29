CatarseMonkeymail.configure do |config|
  config.api_key = ::CatarseSettings.get_without_cache(:mailchimp_api_key)
  config.list_id = ::CatarseSettings.get_without_cache(:mailchimp_list_id)
  config.successful_projects_list = ::CatarseSettings.get_without_cache(:mailchimp_successful_projects_list)
  config.failed_projects_list = ::CatarseSettings.get_without_cache(:mailchimp_failed_projects_list)
end
