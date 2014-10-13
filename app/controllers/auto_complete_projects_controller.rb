class AutoCompleteProjectsController < ApplicationController
  has_scope :search_on_name
  respond_to :html

  def index
    @projects = apply_scopes(Project.visible).most_recent_first.includes(:project_total).limit(params[:limit])
    return render partial: 'project', collection: @projects, layout: false
  end
end
