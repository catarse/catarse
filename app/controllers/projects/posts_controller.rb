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
