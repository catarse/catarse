CatarseMonkeymail.configure do |config|
  config.api_key = ::CatarseSettings[:mailchimp_api_key]
  config.list_id = ::CatarseSettings[:mailchimp_list_id]
  config.successful_projects_list = ::CatarseSettings[:mailchimp_successful_projects_list]
  config.failed_projects_list = ::CatarseSettings[:mailchimp_failed_projects_list]
end
