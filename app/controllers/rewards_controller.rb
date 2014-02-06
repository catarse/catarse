class RewardsController < ApplicationController
  after_filter :verify_authorized, except: %i[index]
  inherit_resources
  belongs_to :project
  respond_to :html, :json

  def index
    render layout: false
  end

  def new
    @reward = Reward.new(project: parent)
    authorize @reward
    render layout: false
  end

  def edit
    authorize resource
    render layout: false
  end

  def update
    authorize resource
    update!(notice: t('projects.update.success')) { project_by_slug_path(permalink: parent.permalink) }
  end

  def create
    @reward = Reward.new(params[:reward].merge(project: parent))
    authorize resource
    create!(notice: t('projects.update.success')) { project_by_slug_path(permalink: parent.permalink) }
  end

  def destroy
    authorize resource
    destroy! { project_by_slug_path(permalink: resource.project.permalink) }
  end

  def sort
    authorize resource
    resource.update_attribute :row_order_position, params[:reward][:row_order_position]
    render nothing: true
  end

  private
  def collection
    @rewards ||= parent.rewards.includes(:contributions)
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end
end
