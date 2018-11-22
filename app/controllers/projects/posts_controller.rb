# frozen_string_literal: true

class Projects::PostsController < ApplicationController
  respond_to :json, only: [:create]
  def parent
    @project ||= Project.find params[:project_id]
  end

  def show
    @post = parent.posts.find params[:id]
  end

  def create
    @post = ProjectPost.new
    @post.project_id = params[:project]
    @post.attributes = permitted_params
    authorize @post

    if @post.save
      for_rewards = params[:project_post][:rewards]
    
      have_saved_for_rewards = true
      
      if !for_rewards.nil?
        for_rewards.each { |reward_id|
          @post_reward = PostReward.new
          @post_reward.project_post_id = @post.id
          @post_reward.reward_id = reward_id
          have_saved_for_rewards = @post_reward.save
        }
      end

      respond_to do |format|
        format.json { render json: { success: 'OK' } }
      end
    end
  end

  def destroy
    authorize resource
    resource.destroy

    flash[:notice] = t('project.delete.posts')
    redirect_to posts_project_path(parent)
  end

  def resource
    @post ||= parent.posts.find params[:id]
  end

  def permitted_params
    params.require(:project_post).permit(policy(resource).permitted_attributes)
  end
end
