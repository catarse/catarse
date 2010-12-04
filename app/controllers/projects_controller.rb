class ProjectsController < ApplicationController

  inherit_resources
  actions :index, :show, :new, :create
  
  def index
    index!{ @title = t 'projects.index.title' }
  end

end
