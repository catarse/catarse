# coding: utf-8
class PostsController < ApplicationController
  inherit_resources
  actions :create
  def create
    create! do
      # Expire the project's blog
      expire_fragment(controller: "projects", action: "show", action_suffix: "updates_#{@post.project.id}")
      return redirect_to controller: :projects, action: :show, id: @post.project.to_param, anchor: 'updates'
    end
  end
end