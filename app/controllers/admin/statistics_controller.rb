class Admin::StatisticsController < Admin::BaseController
  layout 'catarse_bootstrap'
  inherit_resources
  defaults  resource_class: Statistics
  actions :index
end
