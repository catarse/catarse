class Projects::PostsController < ApplicationController
  after_filter :verify_authorized, except: %i[index]
  after_action :verify_policy_scoped, only: %i[index]

  def index
    @posts ||= policy_scope(parent.posts).ordered
    render @posts.page(params[:page]).per(3)
  end

  def parent
    @project ||= Project.find params[:project_id]
  end
end
