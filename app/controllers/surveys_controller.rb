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

  def answer
    authorize resource
    address_answer = SurveyAddressAnswer.find_or_initialize_by(contribution_id: params['contribution_id'])
    if address_answer.address
      address_answer.address.update_attributes(permitted_params[:address_attributes])
    else
      address = Address.create(permitted_params[:address_attributes])
      address_answer.update_attribute(:address, address)
    end
    params['open_questions'].each do |open_question|
      question = resource.survey_open_questions.find open_question['id']
      question.survey_open_question_answers.
        find_or_create_by(contribution_id: params['contribution_id']).update_attribute(:answer, open_question['value'])
    end
    params['multiple_choice_questions'].each do |mc_question|
      question = resource.survey_multiple_choice_questions.find mc_question['id']
      answer = question.survey_multiple_choice_question_answers.find_or_initialize_by(contribution_id: params['contribution_id'])
      if mc_question['value']
        answer.survey_question_choice_id = mc_question['value']
        answer.save!
      end
    end
    render status: 200, json: { success: 'OK' }
  end

  def resource
    @survey ||= Survey.find params[:id]
  end

  def permitted_params
    params.permit(policy(resource).permitted_attributes)
  end

end
