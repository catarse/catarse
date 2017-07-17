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
    open_questions_answer if params[:survey_open_question_answers_attributes]
    mc_questions_answer if params[:survey_multiple_choice_question_answers_attributes]
    contribution.update_attribute(:survey_answered_at, Time.current)
    render status: 200, json: { success: 'OK' }
  end

  protected

  def open_questions_answer
    params[:survey_open_question_answers_attributes].each do |answer|
      question = resource.survey_open_questions.find answer['survey_open_question_id']
      question.survey_open_question_answers
        .find_or_initialize_by(id: answer['id']).update_attributes({contribution_id: answer['contribution_id'], answer: answer['answer']})
    end
  end

  def mc_questions_answer
    params[:survey_multiple_choice_question_answers_attributes].each do |answer|
      question = resource.survey_multiple_choice_questions.find answer['survey_multiple_choice_question_id']
      question.survey_multiple_choice_question_answers
        .find_or_initialize_by(id: answer['id']).update_attributes({contribution_id: answer['contribution_id'], survey_question_choice_id: answer['survey_question_choice_id']})
    end
  end

  def resource
    @survey ||= Survey.find params[:id]
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end
end
