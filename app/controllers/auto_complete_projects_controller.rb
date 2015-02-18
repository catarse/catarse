class AutoCompleteProjectsController < ApplicationController
  has_scope :pg_search
  respond_to :html

  def index
    @projects = apply_scopes(Project.with_state('online')).most_recent_first.includes(:project_total).limit(params[:limit])
    return render partial: 'project', collection: @projects, layout: false
  end
end
