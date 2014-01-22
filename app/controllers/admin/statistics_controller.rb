class Admin::StatisticsController < Admin::BaseController
  layout 'catarse_bootstrap'
  inherit_resources
  defaults  resource_class: Statistics
  add_to_menu "admin.statistics.index.menu", :admin_statistics_path
  actions :index
end
