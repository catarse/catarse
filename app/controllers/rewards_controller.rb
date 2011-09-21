class RewardsController < ApplicationController
  inherit_resources
  load_and_authorize_resource

  def index
    @rewards = Reward.find_by_project_id(params[:project_id])
    render :json => @rewards
  end
end