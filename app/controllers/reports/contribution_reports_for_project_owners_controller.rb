# frozen_string_literal: true

class Reports::ContributionReportsForProjectOwnersController < ApplicationController
  respond_to :csv, :xls

  has_scope :project_id, :reward_id
  has_scope :state, default: 'paid'
  has_scope :waiting_payment, type: :boolean

  def index
    authorize project, :update?
    respond_to do |format|
      if params[:reward_id]
        reward = Reward.find params[:reward_id]
        data = ContributionReportsForProjectOwner.to_csv(collection(false), params[:reward_id])
      else
        data = collection.copy_to_string
      end
      format.csv do
        if params[:reward_id]
          send_data data, filename: "#{project.permalink}#{reward.title ? '_' + reward.title : ''}.csv" 
        else
          send_data data, filename: "#{project.permalink}.csv"
        end
      end

      format.xls do
        send_data Excelinator.csv_to_xls(data)
      end
    end
  end

  protected

  def collection(remove_keys=true)
    @collection ||= apply_scopes(ContributionReportsForProjectOwner.report(remove_keys))
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
