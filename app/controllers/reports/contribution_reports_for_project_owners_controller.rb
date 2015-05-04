class Reports::ContributionReportsForProjectOwnersController < ApplicationController
  respond_to :csv, :xls

  has_scope :project_id, :reward_id
  has_scope :state, default: 'paid'

  def index
    authorize project, :update?
    respond_to do |format|
      format.csv do
        send_data collection.copy_to_string, filename: "#{project.name}.csv"
      end

      format.xls do
        send_data collection.to_xls(
          columns: I18n.t('contribution_report_to_project_owner').values
        ), filename: "#{project.name}.xls"
      end
    end
  end

  protected

  def collection
    @collection ||= apply_scopes(ContributionReportsForProjectOwner.report)
    @collection.project_owner_id(current_user.id) unless current_user.admin?
    @collection
  end

  def project
    @project ||= Project.find params[:project_id]
  end

  def self.policy_class
    ProjectPolicy
  end
end
