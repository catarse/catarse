class ReportsController < ApplicationController

  def financial_by_project
    return unless require_admin
    @csv = Reports::Financial::Backers.report(params[:project_id])
    send_data @csv,
              :type => 'text/csv; charset=utf-8; header=present',
              :disposition => "attachment; filename=financial_report_of_project_#{params[:project_id]}.csv"
  end

  def location_by_project
    return unless require_admin
    @csv = Reports::Location::Backers.report(params[:project_id])
    send_data @csv,
              :type => 'text/csv; charset=utf-8; header=present',
              :disposition => "attachment; filename=location_report_of_project_#{params[:project_id]}.csv"
  end
end