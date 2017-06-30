# frozen_string_literal: true

class SurveysController < ApplicationController
  respond_to :html, :json
  def new
    @project = Project.find params[:project_id]
    authorize @project, :edit?
    render 'projects/surveys/new'
  end

  def create
    @survey = Survey.new
    @survey.attributes = permitted_params
    authorize @survey
    if @survey.save
      render status: 200, json: { success: 'OK' }
    else
      render status: 400, json: { success: 'ERROR' }
    end
  end

  def show
    authorize resource
    render 'projects/surveys/show'
  end

  def answer
    authorize resource
    contribution = Contribution.find params[:contribution_id]
    if permitted_params[:survey_address_answers_attributes]
      contribution.attributes = {addresses_attributes: permitted_params[:survey_address_answers_attributes]}
      contribution.save
    end
    resource.attributes = permitted_params.except :survey_address_answers_attributes
    contribution.update_attribute(:survey_answered_at, Time.current)
    if resource.save
      render status: 200, json: { success: 'OK' }
    else
      render status: 400, json: { success: 'ERROR' }
    end
  end

  protected

  def resource
    @survey ||= Survey.find params[:id]
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end
end
