class RewardsController < ApplicationController
  respond_to :html, :json
  helper_method :resource, :parent

  def sort
    authorize resource
    resource.update_attribute :row_order_position, params[:reward][:row_order_position]
    render nothing: true
  end

  def resource
    @reward ||= parent.rewards.find params[:id]
  end

  def parent
    @project ||= Project.find params[:project_id]
  end
end
