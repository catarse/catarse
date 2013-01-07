class RewardsController < ApplicationController
  load_and_authorize_resource
  inherit_resources
  actions :index, :create, :update, :destroy
  respond_to :html, :json

  def index
    @rewards = Reward.find_by_project_id(params[:project_id])
    render :json => @rewards
  end

  def show
    @reward = Reward.find params[:id]
    render json: @reward.to_json
  end

  def update
    update! do |success, failure|
      success.html { redirect_to project_path(resource.project) }
      success.json { render json: resource.to_json }
      failure.html { redirect_to project_path(resource.project) }
      failure.json { render json: resource.to_json }
    end
  end

  def create
    create! do |success, failure|
      success.html { 
        flash[:notice] = I18n.t('controllers.rewards.create.notice')
        redirect_to project_path(resource.project)  
      }
      failure.html {
        flash[:alert] = I18n.t('controllers.rewards.create.alert')
        redirect_to project_path(resource.project)
      }
    end
  end

  def destroy
    destroy! { project_path(resource.project) }
  end

  protected

  def begin_of_association_chain
    unless action_name == 'show'
      Project.find(params[:project_id])
    end
  end

end
