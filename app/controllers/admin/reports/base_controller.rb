class Admin::Reports::BaseController < Admin::BaseController
  inherit_resources
  responders :csv
  respond_to :csv
  actions :index
end
