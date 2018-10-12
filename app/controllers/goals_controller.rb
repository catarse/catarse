# frozen_string_literal: true

class GoalsController < ApplicationController
  respond_to :html, :json
  helper_method :resource, :parent

  def create
    @goal = Goal.new
    @goal.localized.attributes = permitted_params
    authorize @goal
    if @goal.save
      return respond_to do |format|
        format.json { render json: { success: 'OK', goal_id: @goal.id } }
      end
    else
      render status: 400
    end
  end

  def update
    authorize resource

    resource.localized.attributes = permitted_params
    if resource.save
      if request.format.json?
        return respond_to do |format|
          format.json { render json: { success: 'OK' } }
        end
      end
    else
      return respond_to do |format|
        format.json { render status: 400, json: { errors: resource.errors.messages.map { |e| e[1][0] }.uniq, errors_json: resource.errors.to_json } }
      end
    end
  end

  def resource
    @goal ||= parent.goals.find params[:id]
  end

  def parent
    @project ||= Project.find params[:project_id]
  end

  def destroy
    authorize resource
    # need to send _destroy param to run parent validations
    if parent.update(goals_attributes: [ { id: @goal.id, _destroy: '1' } ])
      render status: 200, json: { success: 'OK' }
    else
      render status: 400, json: { errors_json: resource.errors.to_json }
    end
  end

  protected

  def permitted_params
    params.require(:goal).permit(policy(resource).permitted_attributes)
  end
end
