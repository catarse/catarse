class Reports::BaseController < ApplicationController
  inherit_resources
  responders :csv
  respond_to :csv
  actions :index

  before_filter :require_login
end
