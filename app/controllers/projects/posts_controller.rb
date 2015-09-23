class Projects::PostsController < ApplicationController
  def parent
    @project ||= Project.find params[:project_id]
  end

  def destroy
    authorize resource
    resource.destroy

    flash[:notice] = t('project.delete.posts')
    redirect_to edit_project_path(parent, anchor: 'posts')
  end

  def resource
    @post ||= parent.posts.find params[:id]
  end
end
