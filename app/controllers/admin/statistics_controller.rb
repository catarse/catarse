class Admin::StatisticsController < Admin::BaseController
  inherit_resources
  defaults  resource_class: Statistics
  menu I18n.t("admin.statistics.index.menu") => Rails.application.routes.url_helpers.admin_statistics_path
  actions :index
end
