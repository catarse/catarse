# coding: utf-8
# frozen_string_literal: true

class Projects::ProjectReportExportsController < ApplicationController
  after_filter :verify_authorized
  after_filter :redirect_user_back_after_login, only: %i[index show]

  respond_to :html
  respond_to :json

  def index
    render json: { report_ids: parent.project_report_exports.pluck(:id) }
  end

  def show
    authorize parent, :update?
    resource = parent.project_report_exports.find params[:id]
    if resource.try(:output).try(:url).present?  && resource.state.eql?('done')
      data = 
        if ReportUploader.choose_storage == :fog
          open(resource.output.url)
        else
          open(resource.output.current_path)
        end

      send_data resource.output.url,
        type: resource.content_type,
        x_sendfile: true
      render nothing: true
    else
      render json: { error: 'report_not_done' }, status: 404
    end
  end

  def create
    authorize parent, :update?
    report = parent.project_report_exports.new(permitted_params)
    if report.save
      render json: { id: report.id }
    else
      render json: {  errors: report.errors }, status: 400
    end
 end

  protected

  def permitted_params
    params.require(:project_report_export).permit(:report_type, :report_type_ext)
  end

  def parent
    @parent ||= Project.find params[:project_id]
  end

  def self.policy_class
    ProjectPolicy
  end
end
