class SurveysController < ApplicationController
  respond_to :html, :json
  def new
    authorize resource
    @project = Project.find params[:project_id]
    render 'projects/surveys/new'
  end

  def show
    authorize resource
    render 'projects/surveys/show'
  end

  def resource
    @survey ||= Survey.find params[:id]
  end

end
