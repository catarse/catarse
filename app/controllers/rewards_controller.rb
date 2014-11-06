class RewardsController < ApplicationController
  after_filter :verify_authorized, except: %i[index]
  respond_to :html, :json

  def index
    render layout: false
  end

  def new
    @reward = Reward.new(project: parent)
    authorize @reward
    render_form
  end

  def edit
    authorize resource
    render_form
  end

  def update
    authorize resource
    if resource.update permitted_params[:reward]
      flash[:notice] = t('project.update.success')
      redirect_to edit_project_path(parent, anchor: 'dashboard_reward')
    else
      render_form
    end
  end

  def create
    @reward = parent.rewards.new
    @reward.assign_attributes(permitted_params[:reward])
    authorize @reward
    if @reward.save
      flash[:notice] = t('project.update.success')
      redirect_to edit_project_path(parent, anchor: 'dashboard_reward')
    else
      render_form
    end
  end

  def destroy
    authorize resource
    resource.destroy
    redirect_to project_by_slug_path(permalink: resource.project.permalink)
  end

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

  private
  def render_form
    render partial: 'rewards/form', layout: false
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end
end
