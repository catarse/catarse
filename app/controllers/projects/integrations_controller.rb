class Projects::IntegrationsController < ApplicationController

  helper_method :resource, :parent

  def index
    integrations = parent.integrations.order(created_at: :desc) || []
    render status: 200, json: integrations
  end

  def create
    @integration = ProjectIntegration.new
    @integration.localized.attributes = permitted_params
    @integration.project = parent

    authorize @integration

    if @integration.save
      return respond_to do |format|
        format.json { render json: { success: 'OK', integration_id: @integration.id } }
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
          format.json { render json: { success: 'OK', integration_id: resource.id } }
        end
      end
    else
      return respond_to do |format|
        format.json { render status: 400, json: { errors: resource.errors.messages.map { |e| e[1][0] }.uniq, errors_json: resource.errors.to_json } }
      end
    end
  end

  private

  def permitted_params
    params.require(:integration).to_unsafe_hash.symbolize_keys
  end

  def resource
    @integration ||= parent.integrations.find params[:id]
  end

  def parent
    @project ||= Project.find params[:project_id]
  end
end
