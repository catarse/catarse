class RewardsController < ApplicationController
  load_and_authorize_resource
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

  def show
    @reward = Reward.find params[:id]
    render json: @reward.to_json
  end

  def update
    update! do |success, failure|
      success.html { render nothing: true, status: 200 }
      failure.html { render :edit, layout: nil }
    end
  end

  def create
    create! do |success, failure|
      success.html { render nothing: true, status: 200 }
      failure.html { render :new, layout: nil }
    end
  end

  def destroy
    destroy! { project_by_slug_path(permalink: resource.project.permalink) }
  end

  def sort
    resource.row_order_position = params[:reward][:row_order_position]
    resource.save

    render nothing: true
  end
end
