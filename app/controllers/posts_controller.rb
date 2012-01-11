# coding: utf-8
class PostsController < ApplicationController
  
  inherit_resources
  actions :index, :create
  respond_to :html, :only => [:create]
  respond_to :json, :only => [:index]

  def index
    type = params[:search][:type] if params[:search] and params[:search][:type]
    @posts = Post.all(page: params[:page], type: type)
    respond_with(@posts)
  end
  
  def create
    create! do
      flash[:success] = t('posts.create.success')
      # Expire the project's blog
      expire_fragment(controller: "projects", action: "show", action_suffix: "updates_#{@post.project.id}")
      return redirect_to controller: :projects, action: :show, id: @post.project.to_param, anchor: 'updates'
    end
  end
  
end
