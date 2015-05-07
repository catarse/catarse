class Projects::MetricsController < ApplicationController
  after_filter :verify_authorized
  respond_to :html
  layout false

  def index
    authorize parent, :update?

    @metrics ||= {
      address_state: collection.total_by_address_state,
      confirmed: collection.total_confirmed_by_day,
      confirmed_amount_by_day: collection.total_confirmed_amount_by_day
    }

    respond_with @metrics
  end

  protected

  def collection
    @contributions ||= parent.contribution_details
  end

  def parent
    @project ||= Project.find params[:project_id]
  end

end
