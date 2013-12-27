class RewardsController < ApplicationController
  load_and_authorize_resource except: [:index]
  inherit_resources
  belongs_to :project
  respond_to :html, :json

  def index
    render layout: false
  end

  def new
    render layout: false
  end

  def edit
    render layout: false
  end

  def update
    update!(notice: t('projects.update.success')) { project_by_slug_path(permalink: parent.permalink) }
  end

  def create
    create!(notice: t('projects.update.success')) { project_by_slug_path(permalink: parent.permalink) }
  end

  def destroy
    destroy! { project_by_slug_path(permalink: resource.project.permalink) }
  end

  def sort
    resource.update_attribute :row_order_position, params[:reward][:row_order_position]

    render nothing: true
  end

  private
  def collection
    @rewards ||= parent.rewards.includes(:backers)
  end
end
