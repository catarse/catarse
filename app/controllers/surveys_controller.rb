class SurveysController < ApplicationController
  respond_to :html, :json
  helper_method :resource, :parent
  def new
    @project = Project.find params[:project_id]
    render 'projects/surveys/new'
  end

end
