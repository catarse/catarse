class Adm::Reports::BaseController < Adm::BaseController
  inherit_resources
  responders :csv
  respond_to :csv
  actions :index
end
