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
    if permitted_params[:survey_address_answer]
      SurveyAddressAnswer.find_or_initialize_by(contribution_id: params['contribution_id'])
                         .update_attributes permitted_params[:survey_address_answer]
    end
    open_questions_answer if params['open_questions']
    mc_questions_answer if params['multiple_choice_questions']
    render status: 200, json: { success: 'OK' }
  end

  protected

  def open_questions_answer
    params['open_questions'].each do |open_question|
      question = resource.survey_open_questions.find open_question['id']
      question.survey_open_question_answers
              .find_or_create_by(contribution_id: params['contribution_id']).update_attribute(:answer, open_question['value'])
    end
  end

  def mc_questions_answer
    params['multiple_choice_questions'].each do |mc_question|
      question = resource.survey_multiple_choice_questions.find mc_question['id']
      answer = question.survey_multiple_choice_question_answers.find_or_initialize_by(contribution_id: params['contribution_id'])
      answer.update_attribute(:survey_question_choice_id, mc_question['value'])
    end
  end

  def resource
    @survey ||= Survey.find params[:id]
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end
end
