#encoding: utf-8
class RewardsController < ApplicationController
  inherit_resources
  load_and_authorize_resource
  respond_to :html, :json

  def index
    @rewards = Reward.find_by_project_id(params[:project_id])
    render :json => @rewards
  end

  def udpate
    @reward = Reward.find params[:id]
    update! if can?(:manage, @reward)
  end

  def create
    create! do |success, failure|
      success.html { 
        flash[:notice] = 'Recompensa adicionada com sucesso!'
        redirect_to project_path(resource.project)  
      }
      failure.html {
        flash[:alert] = 'Ops! não foi possivel adicionar a recompensa' 
        redirect_to project_path(resource.project)
      }
    end
  end

  protected

  def begin_of_association_chain
    if current_user.admin
      Project.find(params[:project_id])
    else
      current_user.projects.find(params[:project_id])
    end
  end

end
