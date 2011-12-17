class Projects::BackersController < ApplicationController
  inherit_resources
  actions :index

  def index
    @project = Project.find params[:project_id]
    @backers = @project.backers.confirmed.order("confirmed_at DESC").paginate :page => params[:page], :per_page => 10
    render :json => @backers.to_json(:can_manage => can?(:manage, @project))
  end
end