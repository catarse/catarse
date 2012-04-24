class UpdatesController < ApplicationController
  inherit_resources

  actions :index
  respond_to :json, :only => [ :index ]
  belongs_to :project
end
